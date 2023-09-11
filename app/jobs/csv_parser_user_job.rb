class CsvParserUserJob < ApplicationJob
  queue_as :default

  def perform(id)
    CsvUser
      .where(file_id: id, is_phone_verified: [nil, false])
      .in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        user = ParsedUser.find_by(
          last_name: u.last_name&.downcase,
          first_name: u.first_name&.downcase,
          phone: u.phone&.last(10)
        )
        next unless user

        is_phone_verified = user.is_phone_verified.nil? || user.is_phone_verified == 't'
        array << u.log(:phone, :parsed_users) if is_phone_verified
      end
      CsvUser.upsert_all(array, update_only: %i[is_phone_verified is_phone_verified_source]) if array.present?
    end

    CsvParser.find_by(file_id: id).update(
      status: 5,
      is_phone_verified_count: CsvUser.where(file_id: id, is_phone_verified: true).count
    )
  end
end
