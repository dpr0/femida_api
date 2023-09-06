class CsvParserSolarJob < ApplicationJob
  queue_as :default

  def perform(id)
    person_service = PersonService.instance
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_passport_verified = u.is_passport_verified
        is_passport_verified ||= begin
          resp = person_service.search(u.slice(%i[first_name last_name middle_name birth_date]))
          if resp && resp['count'] > 0
            inform = resp['data'].map { |data| JSON.parse(data['Information'])['D'] }
            tels = inform.select { |x| x.join(' ').include?('ТЕЛЕФОН') }.compact.select do |x|
              ['СВЯЗЬ', 'ТЕЛЕФОН ЮЛ', 'ТЕЛЕФОН РАБОТЫ'].map { |xx| xx if x.join(' ').include? xx }.compact.blank?
            end.compact
            is_phone_verified ||= tels.map { |xx| xx.join(' ').scan(/[0-9]{10,11}/).map { |x| x.last(10) }.select { |x| x.first == '9' } }.flatten.include? u.phone
            is_phone_verified ||= resp['data'].find do |d|
                                    d['LastName']&.downcase == u.last_name && d['FirstName']&.downcase == u.first_name && d['Telephone']&.last(10) == u.phone.last(10)
                                  end.present?
            z = resp['data'].select { |d| d['Passport'] == u.passport }.present?
            z ||= inform.select { |x| x.join(' ').include? 'ПАСПОРТ' }.compact.map { |xx| xx.join(' ').scan(/[0-9]{10}/) }.flatten.include? u.passport
            z
          end
        rescue
          false
        end

        is_phone_verified ||= begin
          resp = person_service.search(phone: u.phone.last(10))
          if resp && resp['count'] > 0
            resp['data'].select { |d| d['LastName']&.downcase == u.last_name && d['FirstName']&.downcase == u.first_name }.present?
          end
        rescue
          false
        end

        zx = {
          id: u.id,
          is_passport_verified: is_passport_verified || false,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: u.is_phone_verified ? u.is_phone_verified_source : (:solar if is_phone_verified),
          is_passport_verified_source: u.is_passport_verified ? u.is_passport_verified_source : (:solar if is_passport_verified)
        }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: %i[is_passport_verified is_phone_verified is_phone_verified_source is_passport_verified_source])
    end

    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count:    CsvUser.where(file_id: id, is_phone_verified:    true).count,
      is_passport_verified_count: CsvUser.where(file_id: id, is_passport_verified: true).count
    )
  end
end
