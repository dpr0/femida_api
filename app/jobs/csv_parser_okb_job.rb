class CsvParserOkbJob < ApplicationJob
  queue_as :default

  def perform(id)
    okbService = 0
    parser = CsvParser.find_by(file_id: id)
    parser.update(status: 4)
    CsvUser.where(file_id: id, is_phone_verified: false).in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_phone_verified ||= begin
                                if u.phone.present? && u.birth_date.present? && u.last_name.present? && u.first_name.present? && u.middle_name.present?
                                  resp = OkbService.call(
                                    telephone_number: u.phone,
                                    birthday: u.birth_date,
                                    surname: u.last_name.downcase,
                                    name: u.first_name.downcase,
                                    patronymic: u.middle_name.downcase,
                                    consent: 'Y'
                                  )
                                  okbService += 1
                                  Rails.logger.info("#{u.id} CsvParserOkbJob_#{id}___okb_service___ #{okbService}")
                                end
                                z = resp && resp['score'] > 2
                                is_phone_verified_source = :okb if z
                                z
                              rescue
                                false
                              end
        zx = {
          id: u.id,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: is_phone_verified_source || u.is_phone_verified_source,
        }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: [:is_phone_verified, :is_phone_verified_source])
    end
    parser.update(status: 5)
  end
end
