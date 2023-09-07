class CsvParserOkbJob < ApplicationJob
  queue_as :default

  def perform(id)
    okbService = 0
    CsvUser
      .where(file_id: id, is_phone_verified: false)
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
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
            Rails.logger.info("#{u.id} CsvParserOkbJob_#{id} score_#{resp['score']} ##{okbService += 1}")
            resp && resp['score'] > 2
          end
        rescue
          false
        end
        zx = {
          id: u.id,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: (:okb if is_phone_verified)
        }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: [:is_phone_verified, :is_phone_verified_source])
    end
    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count: CsvUser.where(file_id: id, is_phone_verified: true).count
    )
  end
end