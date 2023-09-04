class CsvParserInnJob < ApplicationJob
  queue_as :default

  def perform(id)
    parser = CsvParser.find_by(file_id: id)
    parser.update(status: 6)
    CsvUser.where(file_id: id, is_passport_verified: [nil, false]).in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_passport_verified = u.is_passport_verified
        is_passport_verified ||= begin
          inn = InnService.call(
            passport: u.passport,
            date: u.birth_date,
            f: u.last_name&.downcase,
            i: u.first_name&.downcase,
            o: u.middle_name&.downcase
          )
          inn && inn['inn'].present?
        rescue
          false
        end

        zx = {
          id: u.id,
          is_passport_verified: is_passport_verified || false,
          is_passport_verified_source: u.is_passport_verified_source || :inn_service
        }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: [:is_passport_verified, :is_passport_verified_source])
    end

    parser.update(
      status: 7,
      is_passport_verified_count: CsvUser.where(file_id: id, is_passport_verified: true).count
    )
  end
end
