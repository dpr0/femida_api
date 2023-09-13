class CsvParserXxxJob < ApplicationJob
  queue_as :default

  def perform(hash)
    id = hash[:id]
    num = 0
    person_service = PersonService.instance
    CsvUser.where(file_id: id, is_phone_verified: true)
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        req = Request.where(service: :okb).where(u.slice(*%i[phone birth_date last_name first_name middle_name])).order(id: :desc).first
        Rails.logger.info("XXX_okb: ============================ :#{num}") if req
        next if req

        user = ParsedUser.find_by(
          last_name: u.last_name&.downcase,
          first_name: u.first_name&.downcase,
          phone: u.phone&.last(10)
        )
        Rails.logger.info("XXX_parsed_users: ============================ :#{num}") if req
        next if user && (user.is_phone_verified.nil? || user.is_phone_verified == 't')


        resp = person_service.search(phone: u.phone.last(10))
        is_phone_verified = if resp && resp['count'] > 0
          resp['data'].select do |d|
            ['Имя контакта', 'ИМЯ', 'ФИО', 'Клиент', 'Фио', 'ИМЯ КЛИЕНТА'].select do |ff|
              next unless d[ff]

              fio = d[ff].downcase.tr('ё', 'е').split(' ')
              fio.include?(u.last_name) && fio.include?(u.first_name)
            end.present?
          end.present?
        end

        hash = { id: u.id, is_phone_verified: is_phone_verified, is_phone_verified_source: :solar }
        num += 1
        Rails.logger.info("XXX_solar: ============================ :#{num} #{hash}")
        array << hash
        hash
      end
      CsvUser.upsert_all(array, update_only: %i[is_phone_verified is_phone_verified_source]) if array.present?
    end
    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count: CsvUser.where(file_id: id, is_phone_verified: true).count
    )
  end
end
