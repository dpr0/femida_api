class CsvParserCheckJob < ApplicationJob
  queue_as :default

  def perform(id)
    parser = CsvParser.find_by(file_id: id)
    parser.update(status: 4)
    resp = RestClient::Request.execute(
      method: :post,
      url: "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/users/login",
      payload: { email: ENV['FEMIDA_PERSONS_API_LOGIN'], password: ENV['FEMIDA_PERSONS_API_PASSWORD'] }
    )
    body = JSON.parse resp.body if resp.code == 200
    CsvUser.where(file_id: id, is_phone_verified: nil).in_batches(of: 100).each do |batch|
      array = []
      batch.each do |u|
        is_phone_verified = u.is_phone_verified
        is_passport_verified = u.is_passport_verified
        hash = {
          last_name: u.last_name,
          first_name: u.first_name,
          middle_name: u.middle_name,
          birth_date: u.birth_date
        }
        is_passport_verified ||= begin # if drs.present?
          resp = JSON.parse RestClient.post(
            "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/persons/search",
            hash,
            'Authorization' => "Bearer #{body['auth_token']}"
          )
          if resp && resp['count'] > 0
            inform = resp['data'].map { |data| JSON.parse(data['Information'])['D'] }
            tels = inform.select { |x| x.join(' ').include?('ТЕЛЕФОН') }.compact.select do |x|
              ['СВЯЗЬ', 'ТЕЛЕФОН ЮЛ', 'ТЕЛЕФОН РАБОТЫ'].map { |xx| xx if x.join(' ').include? xx }.compact.blank?
            end.compact if tels.present?
            is_phone_verified ||= tels.map { |xx| xx.join(' ').scan(/[0-9]{10,11}/).map { |x| x.last(10) }.select { |x| x.first == '4' } }.flatten.include? u.phone
            is_phone_verified ||= begin
                                    z = resp['data'].select do |d|
                                      d['LastName'].downcase == u.last_name && d['FirstName'].downcase == u.first_name && d['Telephone'].last(10) == u.phone.last(10)
                                    end.present?
                                    is_phone_verified_source = :solar if z
                                    z
                                  end
            z = resp['data'].select { |d| d['Passport'] == u.passport }.present?
            z ||= inform.select { |x| x.join(' ').include? 'ПАСПОРТ' }.compact.map { |xx| xx.join(' ').scan(/[0-9]{10}/) }.flatten.include? u.passport
            is_passport_verified_source = :solar if z
            z
          end
        rescue
          false
        end
        is_passport_verified ||= begin
                                   inn = InnService.call(
                                     passport: u.passport,
                                     date: u.birth_date,
                                     f: u.last_name&.downcase,
                                     i: u.first_name&.downcase,
                                     o: u.middle_name&.downcase
                                   )
                                   z = inn && inn['inn'].present?
                                   is_passport_verified_source = :inn_service if z
                                   z
                                 rescue
                                   false
                                 end

        is_phone_verified ||= begin
                                resp = JSON.parse RestClient.post(
                                  "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/persons/search",
                                  { phone: u.phone.last(10) },
                                  'Authorization' => "Bearer #{body['auth_token']}"
                                )
                                z = if resp && resp['count'] > 0
                                      resp['data'].select { |d| d['LastName'].downcase == u.last_name && d['FirstName'].downcase == u.first_name }.present?
                                    end
                                is_phone_verified_source = :solar if z
                                z
                              rescue
                                false
                              end

        is_phone_verified ||= begin
                                z = ParsedUser.where(
                                  last_name: u.last_name&.downcase,
                                  first_name: u.first_name&.downcase,
                                  phone: u.phone&.last(10)
                                ).exists?
                                is_phone_verified_source = :parsed_users if z
                                z
                              end

        zx = {
          id: u.id,
          is_passport_verified: is_passport_verified || false,
          is_phone_verified: is_phone_verified || false,
          is_phone_verified_source: is_phone_verified_source || u.is_phone_verified_source,
          is_passport_verified_source: is_passport_verified_source || u.is_passport_verified_source
        }
        Rails.logger.info(zx)
        array << zx
      end
      CsvUser.upsert_all(array, update_only: [:is_passport_verified, :is_phone_verified, :is_phone_verified_source, :is_passport_verified_source])
    end

    parser.update(
      status: 5,
      is_phone_verified_count:    CsvUser.where(file_id: id, is_phone_verified: true).count,
      is_passport_verified_count: CsvUser.where(file_id: id, is_passport_verified: true).count
    )
  end
end
