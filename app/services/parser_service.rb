class ParserService
  FIELDS = %i[phone birth_date last_name first_name middle_name].freeze

  def initialize(job_neme, id, field)
    @id = id
    @name = "is_#{field}_verified"
    @count_field = "#{@name}_count"
    @job_name = job_neme.underscore.sub('_job', '')
    @array = []
    @parser = CsvParser.find_by(file_id: id)
    @csv_users = CsvUser.where(file_id: id, @name => [nil, false]).in_batches(of: 100)
    @person_service = PersonService.instance
  end

  def call
    log = @parser.csv_parser_logs.new(info: @job_name)
    log.save(validate: false)
    @csv_users.each do |batch|
      array = batch.map { |u| { id: u.id, @name => true, "#{@name}_source".to_sym => @job_name } if send(@job_name, u) }.compact
      @array += array
      CsvUser.upsert_all(array, update_only: [@name, "#{@name}_source"]) if array.present?
    end

    @parser.update(status: 5, @count_field => CsvUser.where(file_id: @id, @name => true).count)
    log.send("#{@count_field}=", @array.size)
    log.save(validate: false)
  end

  private

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
  end

  def csv_parser_inn(u)
    InnService.call(
      passport: u.passport,
      date: u.birth_date,
      f: u.last_name,
      i: u.first_name,
      o: u.middle_name
    )&.dig('inn').present?
  end

  def csv_parser_user(u)
    user = ParsedUser
           .where('lower(last_name) = ? and lower(first_name) = ?', u.last_name, u.first_name)
           .where(phone: u.phone&.last(10)).first

    user && (user.is_phone_verified.nil? || user.is_phone_verified == 't')
  end

  def csv_parser_db_okb(u)
    slice = u.slice(FIELDS)
    return if slice.values.include? nil

    resp = Request.where(service: :okb).where(slice).order(id: :desc).first
    resp && resp.response.to_i > 2
  end

  def csv_parser_okb(u)
    return if u.slice(FIELDS).values.include? nil

    params = {
      telephone_number: u.phone,
      birthday: u.birth_date,
      surname: u.last_name,
      name: u.first_name,
      patronymic: u.middle_name
    }
    resp = ENV['HOST'] == 'femida-search.online' ? OkbService.call(params) : FemidaProdService.instance.okb_search(params)
    resp&.dig('score')&.> 2
  end

  def csv_parser_card(u)
    phones = if u.phone.present?
      u.phone
    else
      resp = @person_service.search(u.slice(%i[last_name first_name middle_name]))
      return unless resp || resp['count'] > 0

      resp['data'].map { |dd| dd['ТЕЛЕФОН'].scan(/\d/).join.last(10) if dd['ТЕЛЕФОН'].present? }.flatten.compact.uniq
    end
    cards = Card.where(phone: phones).select(:card).map(&:card).compact.uniq
    cards.select { |card| card.present? && (["#{card[0..5]}#{card[-4..-1]}", "#{card[0..5]}******#{card[-4..-1]}"].include? u.info) }.present? if u.info.present?
  end
end
