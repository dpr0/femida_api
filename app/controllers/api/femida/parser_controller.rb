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
    #     #       puts "------------------------------------------------ > #{key}"
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
    #         puts "#{u.phone} - #{resp}"
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
        puts '==================================================== ' if bool
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
    #   puts '==================================================== ' if bool
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
      #   # puts '==================================================== ' if user.present?
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
        xx = tu.blank? ? [] : [bool(tu.is_phone_verified), bool(tu.is_phone_verified_2), bool(tu.is_passport_verified), bool(tu.is_passport_verified_2)]
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
        puts("#{x[0]} --- #{z} >> #{x[-4..-1]}") if (x[-2] == 'TRUE' && z[-1] != 'TRUE') || (x[-4] == 'TRUE' && z[-3] != 'TRUE')
        csv << x
      end
    end
    send_data(zz, filename: 'response.csv', type: 'text/csv')
  end

  def bool(b)
    case b
    when 'true' then 'TRUE'
    when 'false' then 'FALSE'
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

  def sample1
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

  def sample2
    # with_error_handling do
      resp = RestClient::Request.execute(
        method: :post,
        url: "#{ENV['FEMIDA_PERSONS_API_HOST']}/api/users/login",
        payload: { email: ENV['FEMIDA_PERSONS_API_LOGIN'], password: ENV['FEMIDA_PERSONS_API_PASSWORD'] }
      )
      body = JSON.parse resp.body if resp.code == 200
      Sample02.in_batches.each do |batch|
        batch.each do |sample|
          hash = {
            last_name: sample.last_name.downcase,
            first_name: sample.first_name.downcase,
            middle_name: sample.middle_name.downcase
          }
          hash[:birthdate] = sample.birth_date if sample.birth_date.present?

          resp = JSON.parse RestClient.post("#{ENV['FEMIDA_PERSONS_API_HOST']}/api/persons/search", hash, 'Authorization' => "Bearer #{body['auth_token']}")
          next if resp['count'] == 0

          resp['data'].each do |data|
            info = JSON.parse(data['Information'])['D']
            byebug
          end
        end

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
      RetroMcFemidaExtUser.where(is_passport_verified: false).each do |u|
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
