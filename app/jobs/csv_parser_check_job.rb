class CsvParserCheckJob < ApplicationJob
  queue_as :default

  def perform(id)
    parser = CsvParser.find_by(file_id: id)
    parser.update(status: 4)
    file = ActiveStorage::Attachment.find_by(id: id)
    array = []

    resp = RestClient::Request.execute(
      method: :post,
      url: "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/users/login",
      payload: { email: ENV['FEMIDA_PERSONS_API_LOGIN'], password: ENV['FEMIDA_PERSONS_API_PASSWORD'] }
    )
    body = JSON.parse resp.body if resp.code == 200
    Sample02.where(is_passport_verified: false).or(Sample02.where(is_phone_verified: false)).in_batches.each do |batch|
      array = []
      batch.each do |u|
        info = {}
        is_phone_verified = u.is_phone_verified
        is_passport_verified = u.is_passport_verified
        hash = {
          last_name: u.last_name.downcase,
          first_name: u.first_name.downcase,
          middle_name: u.middle_name.downcase,
          birth_date: u.birth_date
        }
        # z = eval(u.resp) if u.resp && u.resp[0..2] == '[{"'
        # drs = z.select { |smpl| smpl['ИМЯ']&.downcase == "#{hash[:last_name]} #{hash[:first_name]} #{hash[:middle_name]}" && smpl['ПАСПОРТ']&.downcase == u.passport }
        #        .map { |x| x['ДАТА РОЖДЕНИЯ'] if x['ДАТА РОЖДЕНИЯ'].present? }.compact.uniq if z.present?
        is_passport_verified ||= begin # if drs.present?
          resp = JSON.parse RestClient.post(
            "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/persons/search",
            hash,
            'Authorization' => "Bearer #{body['auth_token']}"
          )
          if resp && resp['count'] > 0
            is_phone_verified ||= begin
                                    z = resp['data'].select do |d|
                                      d['LastName'] == u.last_name && d['FirstName'] == u.first_name && d['Telephone'].last(10) == u.phone.last(10)
                                    end.present?
                                    info[:is_phone_verified] = :odyssey if z
                                    z
                                  end
            # resp['data'].each do |data|
            #   inform = JSON.parse(data['Information'])['D']
            #   ...
            # end

            z = resp['data'].select { |d| d['Passport'] == u.passport }.present?
            info[:is_passport_verified] = :odyssey if z
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
                                   info[:is_passport_verified] = :inn_service if z
                                   z
                                 rescue
                                   false
                                 end

        is_phone_verified ||= begin
                                resp = JSON.parse RestClient.post(
                                  "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/persons/search",
                                  { phone: u.phone },
                                  'Authorization' => "Bearer #{body['auth_token']}"
                                )
                                z = if resp && resp['count'] > 0
                                      resp['data'].select { |d| d['LastName'] == u.last_name && d['FirstName'] == u.first_name }.present?
                                    end
                                info[:is_phone_verified] = :solar if z
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
                                info[:is_phone_verified] = :parsed_users if z
                                z
                              end

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
                                end
                                z = resp && resp['score'] > 2
                                info[:is_phone_verified] = :okb if z
                                z
                              rescue
                                false
                              end
        array << { id: u.id, is_passport_verified: is_passport_verified || false, is_phone_verified: is_phone_verified || false, info: info }
      end
      Sample02.upsert_all(array, update_only: [:is_passport_verified, :is_phone_verified, :info])
    end
    parser.update(status: 5)
  end
end
