class CsvParserUserJob < ApplicationJob
  queue_as :default

  def perform(id)
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        user = ParsedUser.where(
          last_name: u.last_name&.downcase,
          first_name: u.first_name&.downcase,
          phone: u.phone&.last(10)
        ).first
        is_phone_verified = user.is_phone_verified
        zx = {
          id: u.id,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: (:parsed_users if user.is_phone_verified)
        }
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
