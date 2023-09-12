class CsvParserSolarPasspJob < ApplicationJob
  queue_as :default

  def perform(id)
    person_service = PersonService.instance
    CsvUser
      .where(file_id: id, is_passport_verified: [nil, false])
      .order(id: :desc)
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_passport_verified = u.is_passport_verified
        resp = person_service.search(u.slice(%i[first_name last_name middle_name birth_date]))
        if resp && resp['count'] && resp['count'] > 0
          is_phone_verified ||= resp['data'].find do |d|
            tels = %w[Телефон_сотовый Связь_с_телефоном Телефон_работы ТЕЛЕФОН].map { |x| d[x].scan(/\d/).join.last(10) if d[x].present? }.compact.uniq
            name = d['ИМЯ']&.downcase&.tr('ё', 'е')&.split(' ')
            name&.include?(u.last_name) && name&.include?(u.first_name) && tels.include?(u.phone.last(10))
          end.present?
          is_passport_verified ||= resp['data'].find { |x| x['ПАСПОРТ'] == u.passport }.present?
        end

        if is_phone_verified || is_passport_verified
          zx = {
            id: u.id,
            is_phone_verified: is_phone_verified || false,
            is_passport_verified: is_passport_verified || false,
            is_phone_verified_source: u.is_phone_verified ? u.is_phone_verified_source : (:solar if is_phone_verified),
            is_passport_verified_source: u.is_passport_verified ? u.is_passport_verified_source : (:solar if is_passport_verified)
          }
          Rails.logger.info(zx)
          array << zx
        end
      end
      CsvUser.upsert_all(array, update_only: %i[is_passport_verified is_phone_verified is_phone_verified_source is_passport_verified_source]) if array.present?
    end

    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count:    CsvUser.where(file_id: id, is_phone_verified:    true).count,
      is_passport_verified_count: CsvUser.where(file_id: id, is_passport_verified: true).count
    )
  end
end
