class CsvParserSolarPhoneJob < ApplicationJob
  queue_as :default

  def perform(id)
    person_service = PersonService.instance
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 1000).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = begin
          resp = person_service.search(phone: u.phone.last(10))
          if resp && resp['count'] > 0
            resp['data'].select do |d|
              fio = "#{d['LastName']} #{d['FirstName']} #{d['MiddleName']}".downcase.tr('ё', 'е')
              fio.include?(u.last_name) && fio.include?(u.first_name)
            end.present?
          end
        rescue
          false
        end

        next unless is_phone_verified

        zx = { id: u.id, is_phone_verified: is_phone_verified, is_phone_verified_source: :solar }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: %i[is_phone_verified is_phone_verified_source])
    end

    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count: CsvUser.where(file_id: id, is_phone_verified: true).count
    )
  end
end
