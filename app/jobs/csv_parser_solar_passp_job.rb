class CsvParserSolarPasspJob < ApplicationJob
  queue_as :default

  def perform(id, limit = 100)
    person_service = PersonService.instance
    CsvUser
      .where(file_id: id, is_passport_verified: [nil, false])
      .order(id: :desc)
      .in_batches(of: 100)
      .each do |batch|
      array_phone = []
      array_passp = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_passport_verified = u.is_passport_verified
        hash = u.slice(%i[first_name last_name middle_name birth_date])
        hash[:limit] = limit
        resp = person_service.search(hash)
        if resp && resp['count'] && resp['count'] > 0
          unless is_phone_verified
            r = resp['data'].find do |d|
              tels = %w[Телефон_сотовый Связь_с_телефоном Телефон_работы ТЕЛЕФОН].map { |x| d[x].scan(/\d/).join.last(10) if d[x].present? }.compact.uniq
              name = d['ИМЯ']&.downcase&.tr('ё', 'е')&.split(' ')
              name&.include?(u.last_name) && name&.include?(u.first_name) && tels.include?(u.phone.last(10))
            end.present?
            array_phone << { id: u.id, is_phone_verified: true, is_phone_verified_source: :solar } if r
          end
          unless is_passport_verified
            r = resp['data'].find { |x| [x['ПАСПОРТ'], x['ПАСПОРТ_']].compact.include? u.passport }.present?
            array_passp << { id: u.id, is_passport_verified: true, is_passport_verified_source: :solar } if r
          end
        end
      end
      if array_phone.present?
        Rails.logger.info("=========================== >>> insert #{array_phone.size} rows")
        CsvUser.upsert_all(array_phone, update_only: %i[is_phone_verified is_phone_verified_source])
      end
      if array_passp.present?
        Rails.logger.info("=========================== >>> insert #{array_passp.size} rows")
        CsvUser.upsert_all(array_passp, update_only: %i[is_passport_verified is_passport_verified_source])
      end
    end

    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count:    CsvUser.where(file_id: id, is_phone_verified:    true).count,
      is_passport_verified_count: CsvUser.where(file_id: id, is_passport_verified: true).count
    )
  end
end
