# frozen_string_literal: true

class Api::Femida::ParserController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/whoosh', 'Пользователи whoosh - csv'
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

  api :GET, '/phone_rates', 'Пользователи retro_mc_femida_complete_scored - csv'
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

  api :GET, '/turbozaim', 'Пользователи turbozaim - csv'
  def turbozaim
    # filename = 'turbozaim.csv'
    # file = File.read(Rails.root.join('tmp', 'parser', filename))
    # data = CSV.parse(file, headers: true, col_sep: ';')
    # response = []
    if false
      data.each do |d|
        next if TurbozaimUser.find_by(phone: d['phone'])

        zz = TurbozaimUser.new
        zz.turbozaim_id = d['id']
        zz.dateopen = d['dateopen']
        zz.last_name = d['last_name']
        zz.first_name = d['first_name']
        zz.middlename = d['middlename']
        zz.birth_date = d['birth_date']
        zz.passport = d['passport']
        zz.phone = d['phone']
        zz.femida_id = d['femida_id']
        zz.is_expired_passport = d['is_expired_passport']
        zz.is_massive_supervisors = d['is_massive_supervisors']
        zz.is_terrorist = d['is_terrorist']
        zz.is_phone_verified = d['is_phone_verified']
        zz.is_18 = d['is_18']
        zz.is_in_black_list = d['is_in_black_list']
        zz.has_double_citizenship = d['has_double_citizenship']
        zz.is_pdl = d['is_pdl']
        zz.os_inns = d['os_inns']
        zz.os_phones = d['os_phones']
        zz.os_passports = d['os_passports']
        zz.os_snils = d['os_snils']
        zz.archive_fssp = d['archive_fssp']
        zz.is_passport_verified = d['is_passport_verified']
        # json = JSON.parse(d['os_data'])
        # zz.os_status = json['status']
        # json['data']&.each do |x|
        #   z2 = zz.turbozaim_user_datas.new
        #   x.keys.each_with_index do |key, index|
        #     z2.send("#{field_by(key, index)}=", x[key])
        #   rescue
        #     begin
        #     z2.send("field#{index}=", x[key])
        #     rescue
        #       puts "------------------------------------------------ > #{key}"
        #     end
        #   end
        # end
        zz.save
      end
    end

    if false
      TurbozaimUser.where(is_phone_verified: 'false', os_status: nil).each do |u|
        headers = { 'Authorization': 'Basic b2R5c3NleTo0VVZxbGVoIw==' }
        search = "last_name=#{u.last_name}&first_name=#{u.first_name}&mobile_phone=#{u.phone}&sources%5Bgoogle%5D=on&sources%5Bgoogleplus%5D=on&async=on&mode=xml"
        r1 = Nokogiri::HTML(RestClient.post('https://i-sphere.ru/2.00/check.php', search, headers).body)
        resp = r1.css('response')[0].values
        r2 = Nokogiri::HTML(RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{resp[0]}&mode=xml", headers))
        while r2.css('response')[0].values[1] != '1'
          sleep 1
          r = RestClient.get("https://i-sphere.ru/2.00/showresult.php?id=#{resp[0]}&mode=xml", headers)
          r2 = Nokogiri::HTML(r)
        end
        Hash.from_xml(r2.to_xml).dig('html', 'body', 'response', 'source').each do |zx|
          resp = zx.dig('record', 'field')&.second&.dig('fieldvalue')
          if resp
            puts "#{u.phone} - #{resp}"
            response << u
          end
          u.os_status = resp || 'not_found'
          u.save
        end
      end
    end

    TurbozaimUser.where(is_phone_verified: 'false').each do |u|
      f = u.phone.last(10)
      users = ParsedUser.where(phone: ["7#{f}", f])

      bool = users.select { |user| user.last_name.downcase == u.last_name.downcase && user.first_name.downcase == u.first_name.downcase }.present?
      puts "=================================================== #{bool}"
      u.update(os_status: bool)
    end
  end

  def narod
    with_error_handling do
      # MedJob.perform_later()
      Med1Job.perform_later()
    end
  end

  def expired_passports
    with_error_handling do
      ExpiredPassportsJob.perform_later()
    end
  end

  def retro
    with_error_handling do
      RetroJob.perform_later()
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
