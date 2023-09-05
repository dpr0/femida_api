class CsvParserUserJob < ApplicationJob
  queue_as :default

  def perform(id)
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_phone_verified ||= ParsedUser.where(
          last_name: u.last_name&.downcase,
          first_name: u.first_name&.downcase,
          phone: u.phone&.last(10)
        ).exists?

        zx = {
          id: u.id,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: u.is_phone_verified_source || :parsed_users
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
