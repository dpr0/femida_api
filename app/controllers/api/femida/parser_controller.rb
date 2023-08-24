# frozen_string_literal: true

class Api::Femida::ParserController < ApplicationController
  protect_from_forgery with: :null_session

  def whoosh
    file = File.read(Rails.root.join('tmp', 'whoosh', 'whoosh-small-users.json'))
    data = JSON.parse(file)
    array = data.map { |u| { name: u['name'], phone: u['phone'], email: u['email'] } }
    array.each_slice(30000) do |slice|
      User.insert_all(slice)
    end
    file = CSV.generate do |csv|
      csv << ['name', 'phone', 'email']
      array.each { |data| csv << [data[:name], data[:phone], data[:email]] }
    end
    send_data(file, filename: 'response.csv', type: 'text/csv')
  end

  def phone_rates
    filename = 'sql1.csv''retro_mc_femida_complete_scored.csv'
    file = File.read(Rails.root.join('tmp', 'parser', filename))
    data = CSV.parse(file, headers: true)
    response = []
    # esia = Api::Femida::EsiaController.new

    data.each_slice(100) do |d|
     # z.rate = d['0'].to_f
     # if z.status.nil? && z.rate >= 0.75
     #   esia.send :get_token
     #   next if esia.token.nil?
     #   str = "mbt=+7(#{d['phone'].last(10)[0..2]})#{d['phone'].last(10).last(7)}"
     #   resp = get("/esia-rs/#{"#{esia.class}::PATH".constantize}/recovery/find?#{str}&verifyToken=#{esia.token}", key: :phone)
     #   z.status = resp['description']

      headers = { 'Authorization': 'Basic b2R5c3NleTo0VVZxbGVoIw==' }
      r1 = Nokogiri::HTML(RestClient.post('https://i-sphere.ru/2.00/checkphone.php', "phone=#{ d.map { |x| x['phone'] }.join("%2C") }&sources%5Bgosuslugi_phone%5D=on&async=on&mode=xml", headers).body)
      id = r1.css('div')[-1].children[1].children[2].values[0]
      r2 = Nokogiri::HTML(RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{id}&mode=xml", headers))
      while r2.children[2].children[0].children[0].attribute_nodes[1].value != '1'
        sleep 1
        r = RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{id}&mode=xml", headers)
        r2 = Nokogiri::HTML(r)
      end
      Hash.from_xml(r2.to_xml).dig('html', 'body', 'response', 'source').each do |zx|
        tel = zx['request'].split(' ').last
        z = PhoneRate.find_or_initialize_by(phone: tel)
        if zx['resultscount'] != '0' && zx.dig('record', 'field')&.size == 3
          z.status = zx.dig('record', 'field')[-1]['fieldvalue']
        end
        response << z if z.save
      end
    end

    array = CSV.generate do |csv|
      csv << ['phone', 'esia']
      response.each { |x| csv << [x.phone, x.status] }
    end
    send_data(array, filename: 'response.csv', type: 'text/csv')
  end

  def turbozaim
    # filename = 'turbozaim.csv'
    # file = File.read(Rails.root.join('tmp', 'parser', filename))
    # data = CSV.parse(file, headers: true, col_sep: ';')
    # response = []
    # if false
    #   data.each do |d|
    #     next if TurbozaimUser.find_by(phone: d['phone'])
    #
    #     zz = TurbozaimUser.new
    #     zz.turbozaim_id = d['id']
    #     zz.dateopen = d['dateopen']
    #     zz.last_name = d['last_name']
    #     zz.first_name = d['first_name']
    #     zz.middlename = d['middlename']
    #     zz.birth_date = d['birth_date']
    #     zz.passport = d['passport']
    #     zz.phone = d['phone']
    #     zz.femida_id = d['femida_id']
    #     zz.is_expired_passport = d['is_expired_passport']
    #     zz.is_massive_supervisors = d['is_massive_supervisors']
    #     zz.is_terrorist = d['is_terrorist']
    #     zz.is_phone_verified = d['is_phone_verified']
    #     zz.is_18 = d['is_18']
    #     zz.is_in_black_list = d['is_in_black_list']
    #     zz.has_double_citizenship = d['has_double_citizenship']
    #     zz.is_pdl = d['is_pdl']
    #     zz.os_inns = d['os_inns']
    #     zz.os_phones = d['os_phones']
    #     zz.os_passports = d['os_passports']
    #     zz.os_snils = d['os_snils']
    #     zz.archive_fssp = d['archive_fssp']
    #     zz.is_passport_verified = d['is_passport_verified']
    #     # json = JSON.parse(d['os_data'])
    #     # zz.os_status = json['status']
    #     # json['data']&.each do |x|
    #     #   z2 = zz.turbozaim_user_datas.new
    #     #   x.keys.each_with_index do |key, index|
    #     #     z2.send("#{field_by(key, index)}=", x[key])
    #     #   rescue
    #     #     begin
    #     #     z2.send("field#{index}=", x[key])
    #     #     rescue
    #     #       Rails.logger.info "------------------------------------------------ > #{key}"
    #     #     end
    #     #   end
    #     # end
    #     zz.save
    #   end
    # end
    #
    # if false
    #   TurbozaimUser.where(is_phone_verified: 'false', os_status: nil).each do |u|
    #     headers = { 'Authorization': 'Basic b2R5c3NleTo0VVZxbGVoIw==' }
    #     search = "last_name=#{u.last_name}&first_name=#{u.first_name}&mobile_phone=#{u.phone}&sources%5Bgoogle%5D=on&sources%5Bgoogleplus%5D=on&async=on&mode=xml"
    #     r1 = Nokogiri::HTML(RestClient.post('https://i-sphere.ru/2.00/check.php', search, headers).body)
    #     resp = r1.css('response')[0].values
    #     r2 = Nokogiri::HTML(RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{resp[0]}&mode=xml", headers))
    #     while r2.css('response')[0].values[1] != '1'
    #       sleep 1
    #       r = RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{resp[0]}&mode=xml", headers)
    #       r2 = Nokogiri::HTML(r)
    #     end
    #     Hash.from_xml(r2.to_xml).dig('html', 'body', 'response', 'source').each do |zx|
    #       resp = zx.dig('record', 'field')&.second&.dig('fieldvalue')
    #       if resp
    #         Rails.logger.info "#{u.phone} - #{resp}"
    #         response << u
    #       end
    #       u.os_status = resp || 'not_found'
    #       u.save
    #     end
    #   end
    # end

    # with_error_handling do
      array1 = []
      TurbozaimUser
        .where.not(is_phone_verified: true)
        .where.not(is_phone_verified_2: true)
        .each do |u|
        f = u.phone.last(10)
        bool = u.os_status == 't'
        bool ||= ParsedUser.where(phone: ["7#{f}", f]).select { |user| user.last_name&.downcase == u.last_name.downcase && user.first_name&.downcase == u.first_name.downcase }.present?
        bool ||= begin
          if u.phone.present? && u.birth_date.present? && u.last_name.present? && u.first_name.present? && u.middlename.present?
            resp = OkbService.call(
              telephone_number: u.phone,
              birthday: u.birth_date,
              surname: u.last_name.downcase,
              name: u.first_name.downcase,
              patronymic: u.middlename.downcase,
              consent: 'Y'
            )
          end
          resp && resp['score'] > 2
        rescue
          false
        end
        Rails.logger.info '==================================================== ' if bool
        u.update(is_phone_verified_2: bool)
        array1 << u.id if bool
      end

      array2 = []
      TurbozaimUser.where(is_passport_verified: ['false', nil], is_passport_verified_2: nil).each do |u|
        resp = begin
                 InnService.call(
                   passport: u.passport,
                   date: u.birth_date,
                   f: u.last_name.downcase,
                   i: u.first_name.downcase,
                   o: u.middlename.downcase
                 )
               rescue
                 false
               end
        bool = resp && resp['inn'].present? && resp['error_code'].blank?
        Rails.logger.info '==================================================== ' if bool
        u.update(is_passport_verified_2: bool)
        array2 << u.id if bool
      end
      render status: :ok, json: { array1: array1, array2: array2 }
    # end

    # TurbozaimUser.where(is_phone_verified: ['false', nil]).each do |u|
    #   f = u.phone.last(10)
    #   # users = Leaks5.where('Telephone' => ["7#{f}", f])
    #   users = Leaks2.where(phone: ["7#{f}", f])
    #
    #   bool = users.select { |user| user.last_name.downcase == u.last_name.downcase && user.first_name&.downcase == u.first_name.downcase }.present?
    #   # bool = users.select { |user| user['LastName']&.downcase == u.last_name.downcase && user['FirstName']&.downcase == u.first_name.downcase }.present?
    #   # bool = users.select { |user| user.surname&.downcase == u.last_name.downcase && user.name&.downcase == u.first_name.downcase }.present?
    #   Rails.logger.info '==================================================== ' if bool
    #   u.update(os_status: bool) if bool
    # end
    # with_error_handling do
      verified_phones = []
      # RetroMcFemidaExtUser.where(is_passport_verified: false).each_slice(200) do |slice|
      #   user_phones = slice.map { |u| u.phone.last(10) }.map { |f| ["7#{f}", f] }.flatten
      #   users = ParsedUser.where(phone: user_phones)
      #   slice.each do |retro_user|
      #     u = users.select { |user| user.last_name&.downcase == retro_user.last_name.downcase && user.first_name&.downcase == retro_user.first_name.downcase }.first
      #     next unless u.present?
      #
      #     if u.passport == retro_user.passport && u.passport.present? && retro_user.passport.present?
      #       verified_phones << u.id
      #       retro_user.update(is_passport_verified: true)
      #     end
      #     # if u.passport == retro_user.passport
      #     #   verified_passports << u.id
      #     # end
      #
      #     # if u.is_phone_verified
      #     #   is_verified_phones << u.id
      #     # end
      #   end
      #   # user = users.select { |user| user.last_name.downcase == u.last_name.downcase && user.first_name&.downcase == u.first_name.downcase }.first
      #   # Rails.logger.info '==================================================== ' if user.present?
      #   # array << user.id if user.present?
      # end
      # { verified_phones: verified_phones }
      # z = CSV.generate do |csv|
      #   csv << %w[first_name middle_name last_name phone birth_date passport is_passport_verified is_phone_verified]
      #   RetroMcFemidaExtUser.all.each do |d|
      #     csv << [d.first_name, d.middle_name, d.last_name, d.phone, d.birth_date, d.passport, d.is_passport_verified ? 'true' : 'false', d.is_phone_verified ? 'true' : 'false']
      #   end
      # end
      # send_data(z, filename: 'response.csv', type: 'text/csv')

    # end
  end

  def turbozaim2
    t_users = TurbozaimUser.all.index_by(&:turbozaim_id)
    zz = CSV.generate(col_sep: ';') do |csv|
      csv << %w[id type dateopen last_name first_name middlename birth_date passport phone is_expired_passport is_massive_supervisors is_terrorist is_phone_verified is_18 is_in_black_list has_double_citizenship is_pdl os_inns os_phones os_passports os_snils archive_fssp is_passport_verified score legal_scoring is_criminal score_v2 is_phone_verified is_phone_verified_2 is_passport_verified is_passport_verified_2]
      File.readlines(Rails.root.join('tmp', 'parser', 'turbozaim_xlsx.csv')).each do |z|
        x = z.chomp.delete("\"").split(';')
        next if x[0] == 'id'

        tu = t_users[x[0]]
        xx = tu.blank? ? [] : [bool(tu.is_phone_verified), bool(tu.is_phone_verified == 'true' || tu.is_phone_verified_2), bool(tu.is_passport_verified), bool(tu.is_passport_verified == 'true' || tu.is_passport_verified_2)]
        x << '' if x.size == 26
        csv << x + xx
      end
    end
    send_data(zz, filename: 'response.csv', type: 'text/csv')
  end

  def turbozaim3
    zz = CSV.generate(col_sep: ';') do |csv|
      csv << %w[id type dateopen last_name first_name middlename birth_date passport phone is_expired_passport is_massive_supervisors is_terrorist is_phone_verified is_18 is_in_black_list has_double_citizenship is_pdl os_inns os_phones os_passports os_snils archive_fssp is_passport_verified score legal_scoring is_criminal score_v2 is_phone_verified is_phone_verified_2 is_passport_verified is_passport_verified_2]
      File.readlines(Rails.root.join('tmp', 'parser', 'response_.csv')).each do |z|
        x = z.chomp.delete("\"").split(';')
        next if x[0] == 'id'
        z = x[-4..-1]
        x.insert(26, '') if x.size == 30
        (x[-1] = x[-2]) if x[-2] == 'TRUE' && x[-1] != 'TRUE'
        (x[-3] = x[-4]) if x[-4] == 'TRUE' && x[-3] != 'TRUE'
        Rails.logger.info("#{x[0]} --- #{z} >> #{x[-4..-1]}") if (x[-2] == 'TRUE' && z[-1] != 'TRUE') || (x[-4] == 'TRUE' && z[-3] != 'TRUE')
        csv << x
      end
    end
    send_data(zz, filename: 'response.csv', type: 'text/csv')
  end

  def bool(b)
    case b
    when 'true', true then 'TRUE'
    when 'false', false then 'FALSE'
    else
      ''
    end
  end

  def start_csv
    hash1 = {}
    File.readlines(Rails.root.join('tmp', 'narod', 'moneyman_is_os_phone_req.csv')).each do |line|
      key, value = line.chomp.delete('"').split(",")
      next if key == 'Phone_search'
      hash1[key.last(10)] = value
    end
    hash2 = {}
    File.readlines(Rails.root.join('tmp', 'narod', 'moneyman_scored_adjusted_score.csv')).each do |line|
      key, value = line.chomp.delete('"').split(",")
      next if key == 'phone'
      hash2[key.last(10)] = value
    end

    z = CSV.generate do |csv|
      csv << %w[first_name middle_name last_name phone birth_date passport is_passport_verified is_phone_verified is_os_phone_req adjusted_score]
      FemidaRetroUser.all.each do |data|
        array = [
          data.first_name,
          data.middle_name,
          data.last_name,
          data.phone,
          data.birth_date,
          data.passport,
          data.is_passport_verified,
          data.is_phone_verified,
          hash1[data.phone.last(10)],
          hash2[data.phone.last(10)]
        ]
        csv << array
      end
    end
    send_data(z, filename: 'response.csv', type: 'text/csv')
  end

  def narod
    with_error_handling do
      # MedJob.perform_later()
      # Med1Job.perform_later()
      dfs = DatesFromString.new
      # File.readlines(Rails.root.join('tmp', 'info_parser', 'spasibosberbank.csv')).each do |line|
      #   data = line.force_encoding('windows-1251').encode('utf-8').chomp.delete('"').split(";")
      #   next if data[0] == 'APPLICATION_ID'
      #   phone = data[10].present? ? data[10] : data[2]
      #   next if phone.blank?
      #
      #   date = begin
      #            dfs.find_date("#{data[7]}.#{data[8]}.#{data[9]}").first&.to_date&.strftime('%d.%m.%Y')
      #          rescue
      #            ''
      #          end
      #
      #   z = {
      #     last_name: data[4],
      #     first_name: data[5],
      #     middle_name: data[6],
      #     birth_date: date,
      #     passport: data[12].present? ? data[12] : data[3],
      #     phone: phone.last(10),
      #     address: data[15]
      #   }
      #   hash[phone.last(10)] = z
      # end

      array = []
      File.readlines(Rails.root.join('tmp', 'info_parser', "sbermarket.csv")).each do |line|
        data = line.chomp.split(",")
        next if data[0] == 'firstname'
        phone = data[3]&.last(10)
        next if phone.blank?

        # date = begin
        #          dfs.find_date("#{data[3]}.#{data[4]}.#{data[5]}").first&.to_date&.strftime('%d.%m.%Y')
        #        rescue
        #          ''
        #        end

        hash = {
          last_name: data[1]&.downcase,
          first_name: data[0]&.downcase,
          # middle_name: data[2]&.downcase,
          # birth_date: data[3],
          # passport: data[8],
          phone: phone,
          address: data[2]&.downcase,
          is_phone_verified: data[4] == 'true'
        }
        array << hash # if data[0].present? || data[1].present? || data[2].present?
        if array.size == 10000
          ParsedUser.insert_all(array)
          array = []
        end
      end
      ParsedUser.insert_all(array) if array.present?

      # regexp = /\d{10}$/
      # batch_size = 50_000
      # (0..(ParsedUser.count.to_f / batch_size).ceil).each do |num|
      #   ParsedUser.upsert_all(
      #     ParsedUser.order(:id).limit(batch_size).offset(batch_size * num).all.map { |x| { id: x.id, phone: x.phone&.match(regexp).to_s } },
      #     update_only: [:phone]
      #   )
      #   sleep 0.2
      # end
    end
  end

  def sample
    array1 = []
    File.readlines(Rails.root.join('tmp', 'parser', 'ekapusta_femida_sample.csv')).each do |z|
      x = z.chomp.delete("\"").split(',')
      next if x[0] == 'customer_id'

      x[6] = x[6].last(10)
      x[1] = x[1]&.to_date&.to_s if x[1].present?

      array1 << {
        customer_id: x[0],
        last_name: x[2],
        first_name: x[3],
        middle_name: x[4],
        phone: x[6],
        passport: x[5],
        birth_date: nil
      }
    end
    array1.uniq!
    array1.each_slice(10000) { |slice| Sample02.insert_all(slice) }
  end

  def sample1
    File.readlines(Rails.root.join('tmp', 'parser', 'ekapusta_femida_sample_2.csv')).each_slice(1000) do |slice|
      hash = {}
      slice.each do |z|
        x = z.chomp.split(',')
        next if x[0] == 'customer_id'

        hash[x[0].to_i] = x[7]
      end
      array = Sample02.where(customer_id: hash.keys).map do |u|
        dr = u.birth_date == hash[u.customer_id] ? nil : u.birth_date
        { id: u.id, birth_date: hash[u.customer_id], info: dr }
      end
      Sample02.upsert_all(array, update_only: [:birth_date, :info])
    end
  end

  def sample2
    # with_error_handling do
      resp = RestClient::Request.execute(
        method: :post,
        url: "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/users/login",
        payload: { email: ENV['FEMIDA_PERSONS_API_LOGIN'], password: ENV['FEMIDA_PERSONS_API_PASSWORD'] }
      )
      body = JSON.parse resp.body if resp.code == 200
      Sample02.where(is_passport_verified: false, info: nil).or(
        Sample02.where(is_phone_verified: false, info: nil)
      ).or(
        Sample02.where('id > 55000')
      ).limit(2000).in_batches.each do |batch|
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
    # end
    # z = CSV.generate do |csv|
    #   csv << %w[Phone_search LastName FirstName MiddleName birthday Source Year]
    #   array.each do |d|
    #     csv << [d.phone, d.last_name, d.first_name, d.middle_name, d.birth_date, d.source, d.year]
    #   end
    # end
    # send_data(z, filename: 'response_14.08.2023.csv', type: 'text/csv')
  end

  def expired_passports
    with_error_handling do
      ExpiredPassportsJob.perform_later()
    end
  end

  def retro
    with_error_handling do
      # RetroJob.perform_later()
      array = []

      (86000..92000).to_a.each_slice(1000) do |ids|
        sql = <<-SQL.squish
          SELECT distinct
          r1.id,
          r1.last_name as f,
          r1.first_name as i,
          r1.middle_name as o,
          r1.phone as tel,
          r1.birth_date as dr,
          r1.passport as pasp,
          r2.last_name as f2,
          r2.first_name as i2,
          r2.middle_name as o2,
          r2.phone as tel2,
          r2.birth_date as dr2,
          r2.phone,
          r2.phone_old,
          r2.passport,
          r2.passport_old
          FROM retro_mc_femida_ext_users r1
          LEFT JOIN retro_mc_femida_ext_complete_users r2 on r2.phone_old = r1.phone
          WHERE r1.id in (#{ids.map(&:to_s).join(',')})
          order by id
        SQL
        zx = ActiveRecord::Base.connection.execute(sql).to_a
      # end
      #
      # keys = %i[first_name middle_name last_name phone birth_date passport]
      # z1 = RetroMcFemidaExtUser.where(is_phone_verified: nil).select(keys + [:id]).all.to_a
      # z2 = RetroMcFemidaExtCompleteUser.select(keys + [:phone_old, :passport_old]).all.to_a
      # z1.each do |z|
      #   zz = z2.select { |x| z.first_name == x.first_name && z.middle_name == x.middle_name && z.last_name == x.last_name && z.birth_date == x.birth_date }
      #   ver1 = zz.select { |x| [x.phone, x.phone_old].compact.include?(z.phone) }.present?
      #   ver2 = zz.select { |x| [x.passport, x.passport_old].compact.include?(z.passport) }.present?
      #   array << { id: z.id, is_phone_verified: ver1, is_passport_verified: ver2 }
        zx.each do |x|
          zz = x['f'] == x['f2'] && x['i'] == x['i2'] && x['o'] == x['o2'] && x['dr'] == x['dr2']
          ver1 = zz && [x['phone'], x['phone_old']].compact.include?(x['tel'])
          ver2 = zz && [x['passport'], x['passport_old']].compact.include?(x['pasp'])
          array << { id: x['id'], is_phone_verified: ver1, is_passport_verified: ver2 }
        end
        RetroMcFemidaExtUser.upsert_all(array.uniq { |as| as[:id] }, update_only: [:is_passport_verified, :is_phone_verified])
        array = []
      end
    end
  end

  def retro2
    with_error_handling do
      array = []
      RetroMcFemidaExtUser.where(is_passport_verified: false)
                          .or(RetroMcFemidaExtUser.where(is_phone_verified: false))
                          .each do |u|
        resp = begin
                 InnService.call(
                   passport: u.passport,
                   date: u.birth_date,
                   f: u.last_name.downcase,
                   i: u.first_name.downcase,
                   o: u.middle_name.downcase
                 )
               rescue
                 false
               end
        bool = resp && resp['inn'].present? && resp['error_code'].blank?
        Rails.logger.info('==================================================== ') if bool
        bool2 = u.is_phone_verified
        bool2 ||= ParsedUser.where(phone: ["7#{u.phone}", u.phone]).select { |user| user.last_name&.downcase == u.last_name.downcase && user.first_name&.downcase == u.first_name.downcase }.present?
        bool2 ||= begin
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
                   resp && resp['score'] > 2
                 rescue
                   false
                 end
        u.update(is_passport_verified: bool, is_phone_verified: bool2)
        array << u.id if bool
      end
      array
    end
  end

  private

  def field_by(key, index)
    case key.downcase
    when 'источник' then :source
    when 'имя' then :name
    when 'дата рождения' then :birthdate
    when 'телефон', 'телефон сотовый', 'контактный телефон', 'телефоны' then :phone
    when 'связь с телефоном', 'телефон2' then :phone2
    when 'паспорт' then :passport
    when 'место рождения' then :birthplace
    when 'выдан', 'паспорт кем выдан', 'паспорт выдан', 'кем выдан паспорт' then :passport_organ
    when 'дата выдачи', 'дата выдачи паспорта' then :passport_date
    when 'регион регистрации' then :registration_region
    when 'адрес регистрации', 'адрес регистрации полный', 'город регистрации' then :registration_address
    when 'регион проживания' then :fact_region
    when 'адрес проживания', 'адрес фактический полный' then :fact_address
    when 'место работы', 'место работы дохода' then :workplace
    when 'телефон работы', 'телефон организации', 'телефон работы 1', 'телефон руководителя', 'телефон работы руководитель' then :workplace_phone
    when 'адрес работы' then :workplace_address
    when 'должность' then :workplace_position
    when 'дата актуальности' then :actual_date
    when 'адрес' then :address
    when 'инн' then :inn
    when 'фамилия старые данные' then :old_last_name
    when 'имя старые данные' then :old_first_name
    when 'отчество старые данные' then :old_middle_name
    when 'дата рождения старые данные' then :old_birthdate
    when 'адрес старые данные' then :old_address
    when 'e-mail' then :email
    when 'организация' then :organization
    when 'огрн' then :ogrn
    when 'дата начала действия сведений' then :date_from
    when 'сумма дохода', 'общая сумма дохода', 'сумма годового дохода', 'доход ежемесячный', 'доход по месту работы' then :sum
    when 'ифнс места жительства' then :ifns
    when 'инн организации' then :organization_inn
    when 'vin' then :vin
    when 'модель', 'марка' then :model
    when 'страховщик' then :insurance
    when 'номер полиса', 'Серия/номер полиса' then :polis
    when 'цель использования' then :target
    when 'ограничения' then :limitation
    when 'кбм' then :kbm
    when 'страховая премия' then :premium_sum
    when 'национальность' then :nationality
    when 'номер уд', 'номер ип' then :delo_num
    when 'дата уд', 'дата возбуждения ип' then :delo_date
    when 'статья ук рф', 'основание ип', 'исп. пр-во' then :delo_article
    when 'дата совершения' then :delo_date2
    when 'информация' then :info
    when 'гражданство' then :citizenship
    when 'дата' then :date
    when 'инициатор осп' then :delo_initiator
    when 'сумма долга в рублях' then :credit_sum
    when 'количество дней просрочки' then :overdue_days
    when 'снилс' then :snils
    when 'телефон поручителя' then :phone3
    when 'тип кредита' then :credit_type
    else "field#{index}"
    end
  end
end

# [3093,2931,2933,2934,2950,2944,2951,3751,3878,3879,3880,3881,4325,3309,9224,4456,9293,9445,9450,3893,3896,3551,9499,3823,3138,11046,6070,6071,6073,6075,6076,11047,3905,3096,3099,6102,11082,11784,21215,3148,6127,6128,6131,9923,9935,11074,14053,3152,3153,3041,3054,3056,3071,3073,3076,3084,3190,3261,3273,3370,3169,11075,3187,11820,3378,3381,3382,3410,3512,3518,3288,3289,3596,3618,3619,11099,6666,3624,3630,6684,6685,6687,6689,11101,3651,11852,11872,11877,11882,3454,3456,6742,6743,6745,6747,6749,6755,11141,11146,3682,3685,3686,3688,3689,3690,3757,3758,3760,3761,3532,46018,46453,46737,3540,3541,3542,3800,3851,3853,3854,3866,3599,3600,3889,3990,3991,3992,3015,3486,3735,3398,3428,3477,3480,3569,3602,3643,3876,3434,3435,3845,3850,3495,3497,3498,4462,4463,4465,4467,4470,3871,4992,3894,4214,4216,4219,4220,4518,4046,4064,4066,11902,4368,6860,11163,11932,4370,6824,6825,11172,11174,6826,4562,4563,4564,4784,4634,4787,4096,4097,4099,4127,4145,4175,4386,4464,11178,6838,11209,6883,6884,11919,11213,27256,4302,6920,11236,11285,4367,4185,4211,4265,4267,4269,4277,4794,4260,4263,4284,4286,4289,4306,4334,11304,4517,4519,4520,4351,4353,4354,4380,4381,4394,4395,4397,4399,4400,11989,4409,6998,4931,4450,4541,4543,4545,4546,4577,4578,4885,4601,4602,4651,2139,4702,4720,4927,21045,21055,10700,21076,6007,10920,10862,21117,10099,21180,21182,2647,10573,46858,9971,10686,6484,6491,6492,6495,6496,6497,6732,4777,4779,4781,4782,4802,4811,4812,4836,4893,6964,6977,11410,4900,6984,11435,11579,21420,4905,4906,4908,4947,4963,4978,4980,4983,4973,4974,4019,4257,4259,4282,4283,4863,5502,5063,5066,41855,5092,5093,5094,5096,5099,41851,5102,5103,5112,5114,5116,5117,5118,5119,5669,5137,5152,5166,5167,5296,5297,5298,5300,5301,5303,5176,3355,5309,5346,5380,5527,5362,5218,5219,5220,5253,5288,5263,5304,5305,5306,5307,5433,5434,5312,5313,5314,5317,41931,5356,5357,5358,5382,5383,5388,5389,5390,5765,5767,5768,5450,5550,5496,5535,5548,5624,5625,5559,5673,5572,5573,5576,5599,5603,5604,5606,5610,5634,5665,5666,5696,5697,5698,5699,5684,10741,5685,5688,5690,5704,5736,5740,5794,5774,5748,5755,5783,5786,5995,5812,5813,10760,5857,5854,5855,10767,10771,10778,10781,10787,10790,10793,5846,5851,5852,5853,5866,5870,5929,5930,5931,5941,5943,5712,5797,5084,5282,5723,6481,6158,6159,6160,6161,6162,6175,6179,6207,6208,6209,6210,6219,6315,6316,6317,21479,4984,6848,6411,6412,6418,5906,5907,5908,5909,5910,5925,5933,5934,5946,6488,4989,6489,6490,5976,5978,5979,5994,6093,21521,5992,11510,11599,11532,11559,6086,11580,6018,11692,2662,6047,11745,6064,6066,11906,11802,6077,11815,21549,6109,11838,6122,10908,10911,6147,15830,3245,21614,3257,21659,47027,47121,47237,47273,47245,47310,47294,47284,47261,47333,47378,47376,47360,47353,47329,47380,47517,11864,47749,11916,11983,11011,11033,11036,11028,11029,11032,11034,11039,11222,11416,11441,11678,11651,11065,21793,6283,6510,6530,6534,6535,6536,6537,6538,6583,6779,6586,6587,6617,6652,6082,4934,6719,6720,6723,6700,6709,6711,6870,6863,6836,6841,6876,21890,21896,28333,26109,26127,26181,26276,26332,26352,26400,26405,26417,26456,26557,26504,28399,26605,26668,26676,7245,26691,26699,26721,7354,7387,26856,26852,26914,26923,26909,7626,7660,27392,7814,28638,7822,27551,7951,7979,27577,7956,27615,27704,27708,27782,8485,27927,6980,425,22,51,53,54,161,180,272,273,275,282,283,304,305,307,329,330,350,351,352,378,398,446,447,524,525,527,556,560,564,595,602,604,605,675,676,679,695,771,798,806,842,843,864,867,929,942,976,978,983,7602,7756,7029,7032,7655,7764,7810,7038,7043,7048,7080,28875,28878,28900,4996,4997,4998,4999,4000,4002,4013,4023,4024,4032,4034,4039,4043,4048,4049,4088,4090,4092,4120,4121,4122,4131,4146,4148,4149,4209,4210,4225,1479,1481,1487,1488,1550,1553,1598,1312,1627,1629,1633,1248,1818,1865,1241,1242,4241,4249,1262,4252,4253,4255,1031,1121,1122,1129,1147,1148,1149,1345,1349,8523,1390,1391,1452,1411,1595,1597,1682,1760,1773,1854,1856,1822,1825,1837,8892,4533,4588,4590,4591,4593,4594,4595,4597,4675,4709,4739,4741,4742,4760,4769,4831,4832,4845,4864,4868,4880,4907,4943,8568,48913,9409,9412,9414,9716,9880,4559,4612,4614,4616,4617,4618,5004,5007,5841,9132,28986,8608,5232,25354,25527,47446,9579,8712,5239,5240,47393,5241,5242,5243,5244,5247,5248,5251,5426,47307,5276,2141,2337,2372,1522,2787,2480,2606,2495,2516,2288,2290,2292,2006,2007,2009,2010,2015,2019,2086,2381,2383,2515,2528,2142,2186,2187,2143,2248,2257,2285,2311,2391,2403,2488,2491,2565,2602,2603,1950,1951,2805,2146,2172,5279,5319,5320,5322,5327,5328,5330,47995,5335,5341,5342,5343,25700,44277,12052,12131,12126,12166,12193,12214,6431,6432,6433,12280,12305,12322,12347,6483,6517,12420,6513,12498,6540,6541,6542,12634,12687,6568,6569,6571,6572,12761,12791,6577,12774,12816,6599,6661,6664,6607,12961,6640,6674,6694,6696,6698,12525,12040,12801,6916,6935,6936,6960,8884,6975,7011,7014,7026,7027,23048,12662,7394,23025,12173,7805,12361,7968,7969,7971,12752,12067,13038,7101,13129,7440,13282,13318,13549,13555,13564,13629,13650,8933,13765,13796,13808,13861,13921,13987,23128,13031,13263,5500,5618,5620,5623,5506,5564,5643,5645,5647,5668,5158,5159,5060,5068,5178,5095,5098,5208,5188,5190,5101,5200,5110,5428,5212,5122,5181,5183,8000,7975,8002,8001,8003,8004,8006,8027,8012,8015,8032,8052,8470,8631,8697,8699,8736,8744,8754,8796,3917,8932,9000,3919,3921,8358,3924,8013,8138,13821,4454,4455,4457,8126,8132,8270,8810,8763,8340,8169,14049,8140,8155,8149,8152,8153,14352,14000,8838,5539,5542,8156,23227,23226,5549,5553,5557,8160,8946,8161,8171,8183,14136,14195,14329,8194,8195,14464,14469,8431,14467,14471,14488,14492,14527,14612,8522,12176,14729,8203,9094,9571,9244,9408,9090,9093,9096,9101,9103,9105,9226,9191,9236,9262,9263,9268,14952,4898,8151,9310,9307,9311,14964,14943,8157,8158,9368,9369,4072,9570,9572,9574,9577,9592,9580,9585,4073,4075,5562,5651,5675,9679,9680,4081,4082,4083,4132,9763,9773,9738,9750,9755,9757,9758,9761,9762,9779,9764,9802,9805,9834,9839,9927,8166,9693,8173,9015,8176,9341,4135,9048,9999,14185,4138,14969,14311,9241,9251,9371,8182,9435,14993,8185,8187,9594,9694,8188,9759,9774,3259,8198,3358,15967,15973,9801,8224,8232,15114,15146,8237,15264,15276,8262,8223,8226,9984,11000,15415,8228,8238,10104,15436,10188,10194,10196,10197,10200,10201,10202,15540,8245,8250,8254,10239,10279,8209,8210,10362,10364,2872,8216,10472,2892,2893,2896,10523,8225,2960,2952,8229,10483,2939,2941,2050,2084,2797,2866,10495,2637,2641,2645,2646,43,44,45,183,185,186,214,812,80,253,594,744,765,990,583,243,248,160,551,818,514,190,194,206,207,209,10508,10511,4141,10513,211,574,577,582,739,901,989,586,587,381,170,319,320,635,686,687,709,712,716,10522,10528,10533,847,918,934,935,936,965,969,10,11,13,14,15,23,25,26,27,29,33,10541,10572,8259,49,56,58,61,62,2195,10550,10551,10586,8260,10593,10559,2196,10598,10599,97,99,106,10538,10539,4839,116,120,10549,10552,129,130,133,144,145,149,155,159,15780,171,173,176,177,182,199,202,203,219,221,226,231,234,10562,10566,240,2198,513,278,280,281,286,289,2201,2202,290,296,302,312,314,10580,15858,15878,15913,10865,10871,10873,10934,10931,8267,10014,10100,5043,10487,15627,15710,10676,5076,8269,23525,399,316,332,10696,10716,10728,15803,8273,334,336,355,357,361,416,417,419,369,4669,4670,4671,10149,23468,5580,5581,5585,5589,5773,5682,5895,5653,5607,8284,8288,372,380,391,8293,23555,392,423,548,402,8295,8298,10236,406,408,413,414,427,8303,8315,23585,8317,8319,8327,10372,23553,5609,5663,5629,5635,5636,5637,5677,5678,5776,5777,5679,5680,5657,5659,11355,11869,11005,11006,11017,11025,23528,8279,8282,11176,5884,8285,11267,23527,8292,8296,11371,11372,448,8297,11405,8300,462,463,11589,11577,11582,11585,11590,11587,5886,11608,11617,11633,11638,11641,11646,11658,466,472,478,479,492,493,495,498,504,506,508,519,521,529,530,532,23644,549,552,558,563,596,610,614,616,621,622,623,624,625,637,638,641,642,644,5879,11677,11679,11691,662,665,682,688,689,719,23623,733,743,745,755,760,761,774,788,790,797,820,821,824,828,830,850,866,876,883,884,892,908,914,916,23698,8344,917,922,939,946,951,956,957,964,3433,15527,3448,3451,968,986,987,11694,4722,8353,994,11715,11720,23695,8354,569,580,135,565,188,113,164,297,11734,341,342,367,430,433,455,458,533,652,656,713,718,722,723,724,727,966,11739,11736,8361,971,1981,11756,1505,1477,1478,1868,1799,11703,8376,1523,1528,1532,1534,1536,1545,1634,11746,11753,1615,1617,1625,1649,1371,11776,11767,11781,11770,11773,11775,11778,11782,6013,11783,1738,1739,1740,1745,1747,1748,1749,1751,11786,11792,11797,8382,11799,11803,11804,1756,1809,11805,11807,11816,1810,1812,1816,1857,11818,11819,11827,11774,11785,1899,11798,1900,1946,1457,1460,1461,1462,1466,1967,1968,1970,1971,11806,11808,1976,6270,1979,1508,1511,1512,1516,1518,1520,1571,1572,1334,1360,1384,1385,1490,1491,1017,1033,1010,1011,1016,1020,1305,1521,1509,1510,1576,1581,1583,1669,1864,1220,1229,1244,1270,1271,1273,1274,1278,1279,1281,1282,1283,1291,1293,1294,1298,1302,1303,1306,1310,1311,1318,1321,1323,1326,11769,11823,11832,1472,1014,11831,11834,11849,6303,11843,11858,1889,1890,1106,11845,25757,6327,8488,11851,11853,11855,1993,1994,1996,1998,1030,1035,1037,1107,1045,5707,5709,5710,5711,1048,1057,1058,1064,11873,11878,1166,1066,1072,11883,1111,1112,1126,1128,1130,1131,11889,11890,1133,1168,1135,1157,1158,1170,1173,1174,1176,1178,1189,1192,1211,1212,11900,11895,1213,1214,1342,1346,11896,11905,11907,11914,1352,11904,11920,11923,11927,11913,11915,11917,11924,11925,11928,11931,11941,11946,11949,16097,16347,3470,3471,6374,16044,8396,1357,1362,1365,1376,1378,1380,8350,16082,16119,11550,8458,3474,11314,10600,8411,11444,47603,6248,6251,2032,2035,16959,2040,2041,2045,2047,2048,2049,2053,6263,3487,16006,3488,3490,3492,16268,11156,16327,3507,3508,6300,16451,11196,6356,6357,6358,6359,16832,16837,2056,2057,2058,2059,3659,16903,16977,8422,11433,6372,6452,1447,47355,6910,5742,5726,6211,6244,6245,6221,6222,6223,6224,6229,6230,6231,6233,6235,6329,8426,6912,11003,11826,25834,47299,25842,11230,5595,5597,1395,1400,1402,47326,7078,6041,6042,1404,48086,12666,48267,48309,1405,1406,1407,48524,48561,48655,13000,1410,1412,1413,1414,1421,1426,1428,1430,1433,1436,1437,1438,1439,1440,1444,1446,1453,1554,48865,1556,1558,1559,1561,1564,1565,1566,1567,1650,1652,1653,48917,1659,1664,1665,1667,1679,1696,1698,1699,1702,1714,1716,1762,1765,1781,1794,1851,28075,1870,1909,1918,1920,1922,1927,1928,1930,1931,1933,1934,1000,1026,1027,1083,1186,1604,1609,1691,1693,1826,1829,1838,1839,1841,1843,1844,2639,5945,4477,25967,4486,5948,2663,5951,5952,2664,5954,2338,2379,2556,2340,2351,2415,2417,2418,2419,2686,2689,2691,2693,2711,25987,2713,4490,2718,2719,2791,2724,2725,2727,2735,2742,2743,2744,2758,16674,2426,2434,2436,2438,2440,2441,2442,2446,2447,2452,2454,2458,2461,2462,2467,2471,2104,2105,2106,2111,2115,2117,2120,2121,2772,2774,2779,2788,2134,2815,2818,2821,2822,2823,2824,2825,3,4,2826,2827,2828,2858,2906,2907,2914,2917,2918,6423,15450,2153,2162,2163,2167,2168,2169,2177,3554,3555,2929,2963,2966,2973,2183,6424,6426,6427,2481,2497,2501,2506,2522,2523,2591,2204,2206,22501,6203,6402,6403,43618,6832,2336,6896,6899,6900,6902,6904,6905,2215,2226,2228,2229,4756,4805,4806,4807,4809,4866,4815,6437,4816,4817,6927,5489,43669,2236,2240,2244,2263,6948,6949,6950,1982,6958,6961,2341,2343,6971,6255,6257,6261,6268,6362,6365,2404,2406,2407,2409,5490,6439,24126,16868,15311,509,4016,4087,114,115,2255,2261,2262,2276,2281,4375,4376,4377,43821,2307,4378,4379,2312,2313,2315,2317,2318,2357,48542,2362,2364,2366,204,43928,2382,2384,41888,2387,2392,2393,24179,210,6440,6441,48336,16295,1474,3059,213,216,2425,3167,2398,742,3213,811,4027,4571,6464,2485,2508,6777,4855,22578,16422,2486,4143,992,993,2493,16462,4838,49087,49218,4439,24256,24262,49314,49372,4440,4442,4443,49426,49392,4444,49546,4446,4655,2542,2545,2546,1636,1638,1639,49646,49645,49665,4448,49738,49826,1573,49811,49809,8129,584,585,2547,2569,2570,2577,2605,2608,2609,2610,2611,2616,2618,2619,2620,2669,1642,2671,2673,2674,2675,2677,5529,13218,2795,2799,2803,2806,2864,2865,2809,2831,2833,2837,2845,2897,2935,13220,1577,1578,2920,49912,13235,2946,49984,49977,5848,2976,2977,2988,2997,1675,2930,2936,2942,2000,2475,2091,2064,2065,2070,2179,1701,1730,1731,2348,2349,2397,2410,2651,2656,2666,2668,2524,2631,2634,2076,2077,2698,2699,2449,2707,2767,2768,2368,2748,2830,2374,2377,2421,2888,2154,2155,2588,2589,2211,2213,2328,2217,2246,2247,2251,2460,2625,2423,2424,2715,2716,2717,2731,2451,2473,2100,2101,2102,2786,2812,24342,2850,2851,2161,2622,2207,2301,2140,2188,2189,2190,2193,2222,13372,2759,2762,2763,2835,2836,2839,2840,2842,2882,2002,2991,2993,2995,2996,2531,2867,2635,2877,3102,3104,3109,3110,3111,3112,3115,3116,3117,3118,3119,3121,3125,3130,3413,3419,3429,2428,2430,3788,1076,13483,2465,2469,1585,1588,49779,49380,1097,1095,1100,1101,1102,2780,2785,2269,2811,2270,2175,2271,1590,1592,2829,13522,1526,294,382,2373,1911,1912,1915,1916,2535,3226,246,1538,3227,3231,2557,2701,2751,2752,3301,3312,3314,3317,3318,3319,3320,3323,3324,3371,3586,3899,3902,5899,5901,5902,5904,3932,3935,3763,3774,385,3135,3143,3738,3154,3583,3966,1240,3980,3019,3027,3029,4558,3033,3038,4798,21024,6557,7368,3484,3485,3552,3046,10326,3582,1552,1599,23897,1381,3675,663,1222,1223,1225,1251,3698,21046,775,3705,2159,1489,814,817,893,1499,1501,1630,22134,3051,1199,1200,1848,5281,1289,14223,1363,1364,15009,5339,5345,1768,1771,3708,3064,3065,3068,3069,15581,1722,1723,1724,1719,1725,1726,1734,3914,3536,3082,3185,3186,3191,3721,3726,16992,3260,3263,3267,3270,3278,3281,3360,3361,3362,3339,3081,3327,3374,3377,3388,3346,3588,3589,6068,3392,3404,3247,3248,3254,3519,3520,3521,3522,3525,3543,6192,50873,5503,6193,3207,6083,6088,4314,4417,6090,6092,6094,6095,6096,6097,6098,6099,51020,6103,51184,6104,51164,6105,3178,51241,51245,51296,51377,51373,22363,3768,3197,6135,6137,6138,2499,2502,2503,3547,6348,6349,43115,6350,6352,6353,6376,6377,6379,6381,6382,6384,3250,3287,3792,5507,4877,3296,3297,5285,5385,22435,2580,22441,6575,22465,22489,3091,3608,3610,3611,3627,3628,3858,3305,3308,52020,52896,4572,4324,22582,21251,5262,43000,22657,3616,3617,3621,22686,3652,3416,3421,3908,3660,3662,3671,3672,3691,3692,3693,3694,3747,3748,3514,3517,3783,5487,3801,3807,3808,3812,3813,3842,3849,3861,3863,3868,5631,43175,3872,3892,3938,3939,3940,3941,3981,3994,3995,3997,3998,3999,3918,3928,3929,3459,3744,3006,3775,3150,3157,3963,3964,3973,3974,3976,3195,3047,3188,3349,3350,3351,3352,3354,3333,3393,3491,3673,3677,3232,3642,22699,3754,3234,3237,3238,3244,3251,3432,3442,3447,3458,4560,3461,3464,3465,3466,3473,3504,4613,21482,22716,21622,21684,21691,2205,22745,22726,22701,5418,6260,21777,21850,6790,6791,6792,6793,6797,6799,6801,6802,6804,6811,6812,3235,3556,3557,3558,3570,3578,3579,3058,6818,3166,3553,3574,4852,3942,3944,3945,3947,3949,3951,3952,3953,3954,3955,3958,3960,3176,3020,3026,3179,3043,3181,3182,3184,3158,3203,3205,3982,3984,3985,3986,3987,3168,3172,6820,6822,6823,3175,3344,3214,3215,3216,3217,3218,3219,3220,3222,3223,3696,3676,3701,3765,3766,3819,3829,3085,3087,3088,3913,3060,3067,3145,3018,3034,3790,3028,3002,3003,3004,3008,3011,3022,3010,3369,3697,3707,3710,3711,3712,3717,3723,3727,3736,3740,3745,3883,3764,3828,3836,3838,4471,4473,4475,4476,4479,4483,4487,4489,4494,4495,4496,4497,4498,4499,4500,4501,4503,4730,4505,4506,4507,4509,4511,4512,4515,4582,4970,4134,4221,4222,4223,4226,4010,4264,4228,4229,4230,4294,4295,4566,4060,4004,4005,4140,4840,4044,4050,4052,4055,4056,4067,4069,4313,4317,4318,4319,4606,4565,4619,4620,4622,4623,4624,4625,4629,4630,4735,4737,4820,4821,4822,4889,4748,4753,6165,1755,21015,1779,4774,4846,22828,1815,7004,7007,53920,22898,7053,7063,7081,7085,22927,7092,7098,4761,22917,7022,8020,8022,8023,8025,8028,22906,22972,15216,1873,54776,54827,1876,54975,8093,1885,1886,1893,3431,8527,1898,9013,24682,9085,54503,24718,9003,24735,1940,20145,2252,2253,10033,20776,3750,10095,10112,16291,10114,71,72,17676,10116,10118,10135,10142,93,94,104,10143,136,172,10044,220,228,10068,10072,10073,10079,233,236,257,258,17081,17098,17172,10028,313,343,345,347,17285,17362,375,376,17417,389,390,17435,17455,405,17486,10066,3364,10077,17573,17526,10086,10094,10088,10107,443,445,10953,470,474,17691,10537,17724,17769,10213,10216,17780,477,480,481,482,484,518,17900,17911,539,542,544,546,4844,17989,24818,17064,618,649,17160,693,700,701,732,736,751,754,756,757,778,779,24877,786,804,854,855,869,878,43382,24913,43460,924,973,974,977,981,17939,1953,1219,1237,1232,1297,24956,3373,17495,1043,1044,1046,43532,1053,1073,1075,1137,1138,1139,1146,1171,1209,18018,18030,18031,1448,4093,4094,4847,4860,4098,4104,4105,4107,4111,4112,4114,4183,4115,4116,4128,4153,4155,4793,4199,4011,4012,4028,4030,4036,4038,4118,4696,4129,4130,4144,4150,4151,4152,4157,4158,4420,4421,4422,4163,4165,4166,4167,4169,4171,4792,4173,4174,4797,4929,4930,4336,4179,4186,4187,4190,4192,4198,4201,4203,4206,4426,4207,4232,4274,4275,4243,4248,4428,4430,4432,4434,4250,4258,4281,4437,4555,4304,4329,4468,4330,4878,4344,4345,4347,4349,4492,4356,4358,4359,4361,4363,4364,4365,25995,25645,25651,18038,18041,18150,18156,18158,18161,18293,18304,2135,2757,2808,2082,18474,2218,2219,18675,2235,2237,2238,2309,18931,18945,18964,2532,2533,2538,2539,2575,2596,2598,18013,2880,2881,18758,18124,18139,2922,2924,2926,18790,3782,18275,3970,3971,3048,25139,18530,3291,3366,3400,25171,3615,3636,3638,3648,3669,19128,19092,3796,3798,19293,19316,19283,4015,4020,19441,19456,19478,19574,19619,19629,4197,19698,4233,4235,4271,4272,4246,4247,4795,19828,19852,19861,4299,4301,4305,19882,19888,19931,4327,4338,4413,19340,4574,4575,25664,4764,4814,4824,4825,4826,19226,22770,5141,5193,5194,5196,5197,5205,5215,20771,5414,5439,5441,5528,20626,5446,20194,20198,20199,5566,20242,20307,20336,20425,20364,20390,20454,20513,20515,5738,6259,6139,6140,20655,20673,6141,6142,20733,6143,20961,6144,6145,6839,25685,6915,6004,6005,6008,20201,6032,6034,6035,6037,5958,6002,25247,25290,6408,20432,6485,6486,6504,6511,6526,20797,6564,6566,6582,6581,6603,21293,21956,21954,21338,4389,4407,4584,4586,4416,4527,4534,4549,4552,4553,4881,4692,4583,4599,4603,4638,4643,4644,4645,4646,4647,4649,4652,4656,4657,4659,4660,4661,4917,4684,4685,4690,4691,4698,4699,4723,4724,4726,4727,4728,4888,4921,4923,4708,4714,4715,4738,4765,4767,4789,4823,4827,4879,4828,4833,4895,4862,4869,4871,4874,4875,4901,4909,4910,4916,5384,5393,4942,4948,4950,4952,4993,4994,4953,4955,4957,4958,4961,5394,5126,5128,5134,5135,5136,5206,5460,5143,5144,5146,5148,5255,5149,5471,5156,5278,5280,5161,5177,5349,5351,5352,5353,5354,25266,5186,5210,5363,5217,5222,5419,5260,5264,5266,5270,5271,5274,5302,5436,5311,5348,5360,5361,5366,5367,5368,5369,5371,5373,5377,5396,5398,5400,5484,5463,5530,5415,5416,5420,5431,5531,5443,5452,5455,5457,5508,5509,5516,5518,5519,5520,5521,5770,5692,5693,5694,5759,5984,5727,5744,5751,5762,5785,5787,5798,5802,5803,5805,25688,5807,5815,5820,5821,5823,5824,5830,5832,5834,5835,5840,5889,5839,5843,5858,5867,5868,5869,5874,5875,5876,5912,5913,5914,5915,5917,5918,5919,5922,5926,5927,5932,5939,6997,6999,6019,6020,6022,6024,6025,6028,6029,6054,6056,6167,6060,6061,6062,6063,6168,6169,6174,6176,6146,6149,6153,6155,6584,6177,6181,6184,6185,6186,6187,6188,6195,6197,6198,6199,6202,6274,6278,6279,6280,6281,6287,6288,6291,6294,6296,6297,6306,6308,6309,6310,6312,6313,6321,6322,6324,6326,6332,6334,6335,25350,6387,6388,6393,6395,6398,6399,6410,6414,6419,6420,6422,6508,6524,6554,6555,6733,6594,6546,6547,6550,6551,6613,6614,6615,6712,6866,6601,6605,6610,6612,6620,6622,6623,6626,6632,6633,6634,6635,6641,6643,6646,6651,6653,6654,25389,6759,6760,6761,6765,6766,6767,6768,6772,6773,6774,6108,6110,6112,6113,6116,6117,6118,6119,6120,6121,6576,6675,6676,6678,6679,6680,6681,6683,6690,6691,6714,6716,6717,6718,25369,6692,6693,6697,6705,6736,6738,6750,6752,6756,6786,6787,6788,6861,6837,6843,6846,6847,6849,6850,6852,6854,6878,6879,6881,6885,6886,6887,6888,6889,6890,6891,6892,6893,6930,6938,6939,6940,6942,6945,6946,6972,6978,6982,6986,6988,6989,6991,6993,6875,6252,6254,21274,25418,21257,21669,21726,22395,22409,25451,25466,25463,25494,22971,22077,25496,22216,22233,23791,23839,23994,25521,23793,25536,23439,23276,25580,23209,23200,23138,23113,23027,24051,24987,24014,24816,25600,24611,24777,25328,26139,25486,25510,25731,25541,25956,25922,25052,26011,26025,26098,26302,26570,27617,26838,26938,26829,26030,27000,27014,27670,27071,28444,28527,28160,28202,28000,28119,28104,28383,29086,29199,29700,29312,29122,29659,29658,29803,29854,29987,29091,29116,29801,29916,29580,30127,29150,30237,30201,30286,30115,30074,30398,30393,30502,30441,30632,30697,30726,30795,30773,30870,30867,30839,30350,30787,30026,30315,30117,30376,31067,31247,31049,31143,31142,31091,31203,31251,31238,31352,31437,31424,31489,31567,31598,31539,31605,31903,31899,31912,31965,31515,31225,32265,31125,31074,32370,32500,32451,32527,32752,32849,32945,32045,32111,32224,32001,32233,32873,32911,32032,32052,33059,32555,33211,33262,33254,33591,33730,33902,33914,33403,33296,33276,33013,33010,33807,33019,33224,33293,33388,33371,33440,33519,34729,34228,34242,34243,34259,34402,34448,34490,34483,34503,34530,34552,34624,34653,34685,34715,34756,34805,34832,34843,34862,34873,34900,34935,34951,34981,34035,34763,34834,34841,34510,34560,34515,34958,34465,34017,34019,35005,35357,35052,35068,35089,35157,35190,35306,35387,35418,35358,35575,35642,35658,35615,35754,35758,35764,35887,35913,35998,35980,35974,35814,35808,35489,35700,36193,36642,36519,36315,36020,36126,36090,36139,36194,36217,36232,36291,36313,36304,36343,36367,36395,36396,36422,36471,36513,36465,36607,36766,36757,36752,36746,36722,36051,36972,36993,36869,36866,37023,36585,36418,36793,36963,37298,37012,37018,37802,37619,37124,37158,37222,37221,37261,37310,37353,37363,37390,37460,37518,37537,37549,37570,37593,37597,37602,37608,37625,37783,37749,37845,37898,37947,38059,37913,37561,37001,37075,37622,37079,38039,38086,38090,38161,38217,38394,38424,38436,38445,38567,38586,38621,38668,38749,38754,38777,38805,38822,38875,38901,38091,38288,38356,38537,39455,39164,39060,39112,39151,39159,39228,39240,39297,39329,39412,39421,39438,39479,39596,39711,39784,39770,39857,39830,39816,39981,39273,40036,40192,40178,40258,40259,40272,40268,40501,40720,40709,40498,40762,40747,40798,40864,40940,40977,41823,41556,41737,41977,41976,41951,41424,41572,41216,41275,41163,42866,42862,42985,42986,42359,42399,42375,42756,42802,42794,42118,43911,43511,43085,43084,43212,43180,43278,43859,43471,44548,44022,44106,44180,44600,44594,44540,44643,44848,44943,44993,44760,44679,45011,45062,45199,45352,45427,45481,45498,45682,45673,45526,46054,46122,46258,46326,46424,46474,46422,46497,46601,46567,46566,46612,46622,46755,46792,46762,46760,46906,46879,47139,47053,47043,46301,46185,47085,46059,47153,47435,47396,47383,47441,47440,47632,47814,47907,47902,47978,47252,47008,47308,48173,48536,48516,48686,48708,48691,48684,48797,48794,48974,48967,48064,48007,49003,7842,7013,7068,7069,49348,49487,49555,49568,7071,7090,7430,7355,7301,7638,1003,1004,1109,7658,7659,49095,1432,7299,7493,7034,7041,7017,7311,7940,7561,50870,7023,22364,50201,50186,50297,7074,11894,50365,6430,50432,6442,50537,50522,2225,6443,6444,50570,50671,50637,6727,50621,50825,50850,28417,50131,7015,7201,50744,50571,50520,7003,7376,11861,50310,28656,11813,50033,7591,50600,50007,51128,51500,51561,7688,7712,51673,51655,7047,7050,7058,7059,7067,7072,51918,7073,7091,7095,7102,7105,7106,7111,7113,51835,7131,7134,7143,7151,7165,51632,7116,7122,7129,7132,7133,7144,7147,7155,7156,7157,7160,7166,7170,7175,7179,7182,7191,7192,51177,7195,7196,7208,51125,7211,7219,7222,7228,7180,51058,7189,52072,52060,52112,52153,7193,7198,52143,52118,7202,7203,7205,52264,7213,7217,52341,52404,7220,7221,52473,52425,4935,7237,7236,7240,7242,7253,7273,7255,7279,7284,52664,7263,7285,7286,7267,52693,52715,52752,7270,7274,7276,7291,7289,7298,52853,7234,7241,7244,7248,7256,52999,7257,7259,7262,7265,7269,7272,7277,7278,7282,7288,7334,7302,7304,7306,7310,7312,7313,7315,7316,7321,7322,7325,7326,7333,7340,7343,7349,7303,7308,7317,7324,7329,7336,7342,7345,7350,7352,7363,7365,7369,7383,7379,7389,7373,7393,7400,7401,7410,7415,7423,7426,7427,7372,7377,7382,53130,53132,53081,53151,7392,7396,7398,53245,53233,53361,53355,53332,53409,53468,53463,7407,53681,7408,53651,53696,53742,53764,53793,53876,53848,53979,53977,53830,7418,7421,7424,7452,7431,7434,7442,7443,7445,7463,7469,7473,7481,7432,7436,53574,7439,7447,7448,7451,7456,7462,7465,7478,7479,7488,7491,7499,7500,7557,7507,7509,7528,7531,7536,7547,7497,7498,7502,7513,7514,7517,7519,7520,7524,7527,7532,7539,7542,7544,7548,7551,7552,7555,53201,7556,7538,7565,7598,7571,7573,7574,7577,7581,7584,7592,7606,7611,7621,7572,7576,53280,7582,7586,7587,7604,7619,7583,7605,7617,7683,7628,7630,7634,7640,7642,7645,7661,7681,7684,7624,7627,7631,7633,7668,7671,7674,7679,7680,7685,7687,7690,7700,7709,7744,7714,7718,7746,7704,7726,7732,7742,7750,7692,7696,7697,7702,7705,7706,7710,7713,7724,7727,7731,7733,7734,7738,7743,7745,7786,7758,7772,7774,7779,7781,7782,7783,7798,7808,7812,7816,7753,7760,7761,7763,7769,7775,7780,7787,7791,7794,7796,7809,7815,7766,7817,7843,7850,7867,7828,7830,7831,7836,7853,7862,7863,7869,7873,7881,7829,7837,7838,7860,7865,7871,7877,7882,7885,7884,7890,7891,7897,7898,7917,7901,7930,7910,7913,7918,7926,7928,7943,7946,7886,7888,7892,7893,7894,7900,7905,7911,7915,7920,7923,7929,7931,7934,7936,7945,7947,7952,7974,7949,7970,7977,7978,7980,7984,7985,7996,7957,7991,7993,54091,7995,7999,54225,54366,54479,54522,54628,7549,7145,54734,54695,54849,54877,7223,54924,54391,54493,7061,7086,7768,7083,7788,54096,7992,7194,7008,7055,7070,7126,7378,7137,7976,7981,7152,7154,7204,29384,7225,7226,7227,7239,7261,7266,7323,7290,7295,7458,7358,7390,7425,7450,7470,7472,7512,7525,7620,7541,7543,29407,7545,7546,7550,7553,7596,2623,2627,2628,2629,2286,2297,7677,7650,41647,7676,7686,7701,7723,7755,7806,7784,7793,7827,7835,7879,27215,27425,7872,7914,7883,7944,7948,7973,7075,7646,7663,7643,7990,7042,7260,7330,7422,8294,8335,8137,8088,8090,8105,8107,8112,8227,8672,8682,8964,8999,8421,8628,8630,8633,8597,8636,8751,8756,8758,8899,8901,8268,8489,8934,8459,8437,8474,8482,8484,8503,8511,8512,8520,8521,8524,8472,8478,8487,8499,8506,8124,8515,8519,8528,8531,8534,8552,8556,8563,8576,8585,8529,8530,8543,8545,8549,8550,8554,8558,8560,8562,8567,8573,8577,8579,8582,8584,8586,8587,8589,8592,8596,8600,8604,8615,8619,8593,8625,8644,8601,8603,8605,8623,8643,8995,8649,8611,8612,8614,8621,8658,8675,8676,8677,8661,8694,8663,8713,8674,8678,8693,8716,8719,8721,8686,8688,8690,8700,8705,8715,8717,8718,8731,8725,8727,8776,8742,8750,8767,8772,8774,8781,8785,8723,8728,8738,8777,8780,8786,8808,8822,8823,8825,8813,8834,8841,8844,8788,8802,8805,8807,8811,8814,8819,8824,8836,8839,8846,8866,8854,8878,8863,8885,8890,8893,8895,8914,8859,8873,8874,8877,8879,8882,8889,8896,8897,8903,8905,8912,8913,8915,8916,8927,8930,8940,8941,8975,8953,8969,8925,8943,8944,8947,8949,8955,8967,8972,8973,8976,8978,8981,8983,8985,8990,8992,41078,8075,8139,8141,8622,8792,8240,8306,8325,8330,8332,8336,8338,8339,8363,8364,8365,8369,8377,8379,8384,8389,8334,41140,8462,8096,8098,8101,8104,8106,8108,8109,8038,8049,8054,8059,8060,8061,8073,8118,8122,27748,8246,27752,27763,27904,8011,8095,41214,41205,41203,8113,8115,8119,29920,8047,5491,21819,8062,8065,5003,5017,44490,29871,44270,29596,44218,2299,2304,2322,2331,2332,2021,2020,2024,2028,2029,2001,2574,2529,2530,2548,8051,44382,2551,2657,2832,2903,2955,2956,2980,2079,8085,8081,8057,8067,8086,8102,8116,8127,8131,8143,8165,8626,8180,8215,8189,8201,8231,8248,8265,8134,8286,8291,8346,5956,5960,5961,5964,5966,5968,5969,5974,8356,8362,8741,8635,8639,8652,8655,8687,20706,8748,8761,8762,8765,44529,8773,1823,1824,5977,5019,5810,5892,5009,5022,5026,5029,8783,8790,8798,8804,8847,8966,8849,8861,5015,5020,5038,5425,5747,5883,5885,5027,5028,5031,5032,5033,5034,5036,5037,5039,5041,5045,5077,5078,5417,5449,5079,5406,5069,5070,5071,45954,5072,5075,5407,5408,5409,5970,5996,5998,5049,5054,8402,5055,5056,5059,5292,5474,5477,5478,8876,8886,8906,8911,8963,8970,8986,8498,8996,8578,8434,8352,8394,8442,8452,8461,8513,8570,8620,8641,8670,8701,8164,8192,8193,8196,8197,8239,8257,8290,8378,8406,8439,8443,8403,8405,8414,8427,8755,8759,8760,8764,8766,8768,8858,8219,8234,8123,8029,8078,8079,8091,8092,8069,8071,8082,8557,8831,8870,8960,8034,8651,8952,8468,8559,9704,9193,9054,9011,9028,9030,9010,9012,9924,9930,9941,9892,9899,9901,9629,9114,9119,9173,9122,9124,9130,9157,9165,9167,9118,9123,9125,9126,9128,9150,9156,9160,9161,9162,9171,9179,9211,9212,9231,9232,9233,9176,9177,9187,9194,9200,9204,9205,9208,9216,9217,9218,9227,9228,9230,9234,9237,9243,9278,9289,9275,9279,9282,9271,9284,9299,9256,9258,9274,9280,9281,9285,9287,9294,9298,9302,9312,9314,9318,9321,9323,9324,9348,9327,9329,9332,9333,9338,9347,9349,9351,9356,9358,9361,9364,9367,9317,9328,9334,9342,9346,9353,9355,9365,9384,9386,9390,9396,9400,9401,9405,9406,9410,9424,9429,9375,9383,9389,9393,9399,9423,9426,9427,9432,9437,9451,9467,9452,9459,9463,9478,9483,9485,9488,9491,9492,9495,9496,9439,9441,9456,9457,9460,9466,9470,9473,9475,5480,5485,5000,5013,5014,5880,5295,5050,5051,5052,5192,5235,5237,9476,9482,9487,9490,9493,9494,9500,9514,9511,9515,9517,9518,9522,9530,9533,9535,9544,9546,9547,9548,9507,9513,9520,9524,9528,9543,9545,9549,9551,9553,9554,9560,9561,9586,9605,9613,9614,9619,9567,9569,9575,9578,9583,9589,9595,9597,9598,9599,9600,9601,9608,9626,9630,9677,9686,9642,9687,9646,9647,9648,9649,9650,9689,9655,9660,9662,9670,9672,9675,9635,9636,9638,9639,9651,9663,9682,9692,9708,9696,9699,9719,9748,9727,9734,9737,9739,9744,9746,9749,9695,9698,9700,9702,9703,9706,9709,9715,9718,9720,9721,9725,9730,9817,9792,9807,9808,9816,5238,5258,5287,5310,5283,5291,5422,5437,5438,5764,5468,5469,5488,5772,5630,5633,5652,5656,5661,5703,9822,5717,5719,5725,5731,5732,5735,5778,5780,5781,5792,5829,5863,9771,9781,9785,9789,9790,9800,9806,9823,9826,9830,9854,9844,9857,9865,9866,9867,9874,9879,9882,9885,9886,9825,9843,9847,9848,9851,9853,9855,9858,9860,9863,9864,9872,9878,9888,9890,9914,9939,9904,9945,9916,9921,9912,9918,9928,255,6454,6000,6039,6040,6044,9938,9940,9954,9960,9959,9970,9963,9975,9980,9982,9986,9989,9991,9993,9995,9998,9272,9164,9056,9060,9040,9042,9026,9031,9032,9034,9035,9038,9044,9046,9047,9051,9057,9053,9061,9063,9078,9066,9068,9069,9070,9071,9072,9073,9109,9087,9097,9099,9106,9110,9404,9766,335,337,338,6458,6459,6460,6461,6463,6468,6470,6472,6474,6477,6482,6518,6556,6559,6560,6561,6663,6665,6859,6781,6001,9008,364,365,9041,9043,9637,9064,9065,9828,9082,442,444,9343,9100,9108,9115,468,9350,9265,489,9139,9143,9705,9712,536,9182,9458,9188,9861,9199,9206,627,629,636,9245,9283,9288,9462,9304,9306,691,9465,699,9869,9344,9489,9379,721,9413,9416,9417,9418,9568,9502,746,9444,766,767,768,9519,10034,856,857,10117,10119,10403,10402,10405,10423,9542,10596,10561,10655,10659,1329,1331,1332,10022,1984,1985,1988,1989,1144,10560,1141,9556,1180,1181,1182,1184,1185,10746,1449,1469,1470,10988,1603,1621,1657,1687,10437,10397,1867,1784,1785,1787,1795,1796,1804,1805,1858,11780,11979,11993,11332,11148,11147,11254,11271,11275,11278,9611,9612,11356,11375,11365,11366,11340,11431,11572,11598,11605,2060,11611,11940,2192,2216,2234,6833,6914,2335,9633,11031,11044,2665,2088,2092,2093,2095,2097,2098,2099,9653,9665,9714,317,9726,29205,933,9780,9788,29704,9803,9813,9838,29707,47,9821,9824,103,2868,9833,111,2869,2873,2876,9835,9871,1834,9877,138,139,142,143,9902,9907,9913,9919,9949,9969,9088,9798,9814,9943,9950,9017,9020,9021,9025,9246,9510,9402,9820,10680,10690,10698,10701,10710,10726,10702,10724,10678,10755,10758,10747,10756,10432,10442,10490,10492,10503,10476,10515,10517,10519,10521,10525,10481,10480,10518,10530,10486,10496,10498,10512,10730,299,303,10407,10098,10113,10105,10146,10147,10054,324,10059,10067,10080,10081,10019,10021,10023,10036,10039,10055,10074,10091,10809,10161,10278,10329,10540,10665,10366,10514,349,10535,10618,10688,10824,10961,10957,10968,10004,377,10005,10012,10002,10007,10010,10011,10013,10015,10026,10035,10027,10037,10485,10584,10913,10205,10411,10070,10106,10125,10127,10129,10136,10141,10148,10167,10169,10175,10181,394,396,10182,10192,10204,10154,10155,10165,10177,10178,10179,10183,10191,10206,10212,10214,10220,10222,10223,10224,10226,10228,10230,10244,10252,10253,10257,10258,10261,10262,10277,10218,10229,10234,10235,10242,10248,10249,10250,10251,10255,10256,10259,10263,10272,10219,10285,10286,10287,10288,437,10289,10292,10300,10302,10303,10314,10324,10333,10335,10280,10281,10295,10308,10310,10312,10315,10320,10322,10323,10325,10338,10339,10290,10306,10318,10350,10352,10353,10358,10381,10382,10387,10389,10346,10349,10357,10369,10373,10374,10376,464,465,10378,10391,10424,10427,10430,10439,10440,10454,10457,10466,10469,10470,10408,10415,10419,10421,10428,10449,10453,10455,10460,10464,10468,10413,10563,10567,10571,10582,10588,10590,10595,10636,10647,10657,10635,10616,10617,10620,10628,10631,10639,10641,486,487,491,10642,10643,10646,10650,10652,10661,10601,10605,10615,10621,10626,10638,10649,10654,10663,10666,10673,10674,10669,10672,10713,10675,10719,10721,10692,10722,10695,10720,10759,10770,10773,10786,10788,10792,10783,10785,10791,10795,10800,10801,10797,10804,10805,10806,10808,10798,10821,10822,10835,10829,10830,10834,10840,10844,10845,10854,10810,10812,10814,10816,10823,10828,10832,10847,10853,612,613,10858,10882,10885,10883,10898,10895,10910,10915,10896,10918,10879,10880,10888,10894,10900,10907,648,10914,10919,10921,10897,10917,10878,10924,10932,10933,10946,10943,10954,10945,10959,10960,10962,10963,10965,10967,10970,10948,10981,10941,10950,10955,10978,10986,10996,10990,10993,672,673,10997,10999,10060,10006,10124,10024,10047,10048,10082,10083,10085,10109,10742,10046,10075,10078,10089,10097,752,753,758,759,10108,10748,10444,781,10475,10482,10630,10507,793,10520,10564,10526,826,10527,834,835,836,837,10543,851,852,861,10581,10594,16859,873,874,10660,909,910,10611,10612,10613,10614,10634,10637,10640,10644,10656,10685,948,10752,10916,998,10765,10775,10794,10802,730,1455,10889,10831,10842,10866,10904,1484,10947,10493,1544,1547,10982,10168,10170,10198,10506,10132,10138,28506,1619,10140,10151,10152,1735,10187,10193,10245,10365,10274,1874,1875,1879,1881,10426,10316,10359,10371,10379,10386,10409,10418,1422,1482,1549,1674,1233,1238,10668,1256,1257,1260,10745,10923,11167,11326,11556,11549,11560,11561,11563,11565,11553,11571,11513,11516,11517,11663,11657,11661,11666,11671,11688,1308,11696,11701,11713,11711,11717,11726,11733,1338,1339,1340,1341,11732,11903,11616,11795,11953,11901,11116,11793,11170,11378,11975,11255,11450,11837,11999,11610,1367,11109,11184,11379,11567,11862,11868,11870,11874,11875,11879,11881,11885,11891,1991,11893,11841,11960,11969,11246,11012,11015,11035,11043,11050,11053,11055,11057,11067,11070,11060,11061,11064,11066,11087,11071,11072,11106,11107,11110,11113,11062,11086,11088,11089,11090,11098,11114,11100,11102,11105,11117,11128,11121,11133,11125,11130,11140,11134,11142,11144,11151,11154,11166,11159,11164,11136,11175,11180,11181,11135,11137,11183,11185,11186,11187,11195,11190,11197,11200,11201,11192,11210,11211,11216,11221,11227,11229,11217,11245,11224,11220,11194,11207,11215,11247,11248,11231,11233,1114,11238,11240,11244,11252,11251,11257,11258,11259,11263,11266,11265,11272,11273,11269,11270,11288,11294,11296,11282,11305,11291,11281,11286,11292,11289,11290,11250,11299,11310,11313,11315,11316,11325,11327,11331,11339,11333,11336,11362,11353,11354,11346,11345,11351,11357,11369,11377,1194,11334,11384,11385,11387,11394,11390,11391,11397,11393,11395,11404,11409,11422,11413,11427,11415,11436,11438,11442,11411,11418,11419,11423,11425,11407,11443,1344,11445,11453,11455,11465,11467,11474,11494,11446,11504,11477,11447,11478,11482,11486,11493,11489,11495,11496,11501,11519,11523,11524,11534,11529,11539,11533,11538,11543,11552,11535,11537,11548,11555,11557,11562,11554,11511,11564,11612,11607,1393,1398,1399,11622,11619,11627,11624,11635,11601,11603,11614,11621,11623,11625,11631,11628,11630,11602,11672,11673,11668,11690,11643,11653,11654,11659,11660,11669,11740,11742,11751,11754,11755,11757,11758,11760,11714,11929,11933,11935,11957,11947,11897,11965,11990,11991,11997,11964,11967,1435,11977,11980,11998,11958,11085,11264,11324,11341,1660,1661,11376,1708,1710,11430,11464,1772,11509,1789,1790,1791,1792,11485,11514,11515,11545,11594,11604,11634,29952,11728,11731,11001,11004,11010,1098,1231,1254,1901,1902,1963,1827,2126,2128,11019,2810,2886,2898,29190,5047,5048,29189,28068,27608,3025,41417,41376,3718,41490,41476,28140,45046,45294,45286,45493,45491,8447,8430,8436,8441,8444,8451,8454,29183,3700,5293,25638,3622,27087,3730,3739,9908,3283,9974,9979,9987]
