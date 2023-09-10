class CsvParserDbOkbJob < ApplicationJob
  queue_as :default

  def perform(id)
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified ||= begin
          if u.phone.present? && u.birth_date.present? && u.last_name.present? && u.first_name.present? && u.middle_name.present?
            resp = Request.where(service: :okb).where(u.slice(*%i[phone birth_date last_name first_name middle_name])).order(id: :desc).first
            resp && resp.response.to_i > 2
          end
        rescue
          false
        end
        if is_phone_verified
          zx = {
            id: u.id,
            is_phone_verified: is_phone_verified || false,
            is_phone_verified_source: (:db_okb if is_phone_verified)
          }
          Rails.logger.info(zx)
          array << zx
        end
      end
      CsvUser.upsert_all(array, update_only: [:is_phone_verified, :is_phone_verified_source]) if array.present?
    end
    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count: CsvUser.where(file_id: id, is_phone_verified: true).count
    )
  end
end
