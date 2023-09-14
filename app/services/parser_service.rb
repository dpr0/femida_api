class ParserService
  def initialize(job_neme, id, field)
    @id = id
    @field = field
    @job_name = job_neme.underscore.sub('_job', '')
    @array = []
    @parser = CsvParser.find_by(file_id: id)
    @csv_users = CsvUser.where(file_id: id, "is_#{field}_verified": [nil, false]).in_batches(of: 100)
    @person_service = PersonService.instance
    @name = "is_#{@field}_verified"
  end

  def call
    array = []
    @csv_users.each do |batch|
      batch.each { |u| array << log(u.id) if send(@job_name, u) }
      @array += array
      CsvUser.upsert_all(array, update_only: [@name, "#{@name}_source"]) if @array.present?
    end

    field = "#{@name}_count"
    count = CsvUser.where(file_id: @id, is_phone_verified: true).count
    @parser.update(status: 5, field => count)
    @parser.csv_parser_logs.create(field => @array.size, info: @job_name)
  end

  private

  def log(id)
    hash = { id: id, @name => true, "#{@name}_source".to_sym => @job_name }
    Rails.logger.info(hash)
    hash
  end

  def csv_parser_solar_phone(u)
    resp = @person_service.search(phone: u.phone.last(10))
    if resp && resp['count'] && resp['count'] > 0
      resp['data'].select do |d|
        ['Имя контакта', 'ИМЯ', 'ФИО', 'Клиент', 'Фио', 'ИМЯ КЛИЕНТА'].select do |ff|
          next unless d[ff]

          fio = d[ff].downcase.tr('ё', 'е').split(' ')
          fio.include?(u.last_name) && fio.include?(u.first_name)
        end.present?
      end.present?
    end
  rescue StandardError
    # Ignored
  end

  def csv_parser_inn(u)
    inn = InnService.call(
      passport: u.passport,
      date: u.birth_date,
      f: u.last_name&.downcase,
      i: u.first_name&.downcase,
      o: u.middle_name&.downcase
      )
    inn && inn['inn'].present?
  rescue StandardError
    # Ignored
  end

  def csv_parser_user(u)
    user = ParsedUser
           .where('lower(last_name) = ? and lower(first_name) = ?', u.last_name&.downcase, u.first_name&.downcase)
           .where(phone: u.phone&.last(10)).first

    user && (user.is_phone_verified.nil? || user.is_phone_verified == 't')
  end

  def csv_parser_db_okb(u)
    slice = u.slice(*%i[phone birth_date last_name first_name middle_name])
    return if slice.values.include? nil

    resp = Request.where(service: :okb).where(slice).order(id: :desc).first
    resp && resp.response.to_i > 2
  end

  def csv_parser_okb(u)
    slice = u.slice(*%i[phone birth_date last_name first_name middle_name])
    return if slice.values.include? nil

    resp = OkbService.call(
      telephone_number: u.phone,
      birthday: u.birth_date,
      surname: u.last_name.downcase,
      name: u.first_name.downcase,
      patronymic: u.middle_name.downcase,
      consent: 'Y'
    )
    resp && resp['score'] > 2
  end

  def csv_parser_xxx(u)
    csv_parser_db_okb(u) || csv_parser_user(u) || csv_parser_solar_phone(u)
  end

  def csv_parser_(_); end
end
