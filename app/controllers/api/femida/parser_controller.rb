# frozen_string_literal: true

class Api::Femida::ParserController < ApplicationController
  protect_from_forgery with: :null_session

  def phone_rates
    filename = 'retro_mc_femida_complete_scored.csv'
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
  end

  def narod
    # with_error_handling do

      array = []
      z = 0
      File.readlines(Rails.root.join('tmp', 'parser', 'production.log')).each do |line|
        # z = 0 if z == 4
        if line.include?('=========== Verify REQUEST: ============')
          z += 1
          next
        end
        next if z == 0
        z += 1
        if line.include?('https://idv.bki-okb.com/verify')
          str = line.split('applicant":').last.split(',"submission').first
          if str == 'null'
            z = 0
            next
          end
          data = JSON.parse(str.downcase.tr('ё', 'е'))
          @hash = {
            service:     :okb,
            phone:       data['telephone_number'].last(10),
            last_name:   data['surname'],
            first_name:  data['name'],
            middle_name: data['patronymic'],
            birth_date:  data['birthday'].to_date.strftime('%d.%m.%Y')
          }
          next
        elsif line.include?('=========== Verify RESPONSE: ===========')
          next
        elsif line.include?('{"score":')
          @hash[:response] = JSON.parse(line)['score']
          array << @hash
          @hash = {}
          z = 0
        end
      end
      array.uniq.each_slice(BATCH_SIZE) { |slice| Request.insert_all(slice) }
      # regexp = /\d{10}$/
      # batch_size = 50_000
      # (0..(ParsedUser.count.to_f / batch_size).ceil).each do |num|
      #   ParsedUser.upsert_all(
      #     ParsedUser.order(:id).limit(batch_size).offset(batch_size * num).all.map { |x| { id: x.id, phone: x.phone&.match(regexp).to_s } },
      #     update_only: [:phone]
      #   )
      #   sleep 0.2
      # end
    # end
  end

  def enrichment
    id = params[:id]
    file = ActiveStorage::Attachment.find_by(id: id)
    person_service = PersonService.instance

    array = []
    file.open do |f|
      46828.times do |i|
        ar = f.readline.force_encoding('UTF-8').chomp.delete("\"").downcase.tr('ё', 'е').split(';')
        next if ar[0] == 'название компании (полное)'

        last_name, first_name, middle_name = ar[0].split(' ')
        array << { last_name: last_name, first_name: first_name, middle_name: middle_name, inn: ar[3] }
      rescue
        break
      end
    end
    array2 = []
    array.each_with_index do |u, i|
      hash = u.slice(*%i[last_name first_name middle_name])
      csv_users = CsvUser.where(hash.merge(file_id: id))
      csv_users.each do |csv_user|
        csv_user.update(external_id: u[:inn]) if csv_user.external_id.nil?
      end
      Rails.logger.info "#{i}: #{csv_users.present?} - #{u}"
      next if csv_users.present?

      resp = person_service.search(u)
      if resp && resp['count'] && resp['count'] > 0
        birth_dates = resp['data'].map { |d| d['ДАТА РОЖДЕНИЯ'] }.compact.uniq
        hash[:birth_date] = birth_dates.join(', ')

        birth_dates.each do |birthdate|
          resp2 = person_service.search(hash.merge(birth_date: birthdate))
          if resp2 && resp2['count'] && resp2['count'] > 0
            phones = resp['data'].map do |dd|
              [
                'Связь с телефоном абонентом', 'Телефон_сотовый', 'Связь_с_телефоном', 'Телефон_работы', 'Телефон работы',
                'телефон', 'Телефон', 'Телефоны', 'ТЕЛЕФОН', 'Телефон места работы', 'Телефон_регистрации', 'Телефон_проживания'
              ].map { |x| dd[x].scan(/\d/).join.last(10) if dd[x].present? }.compact.uniq
            end.flatten.compact.uniq
            hash[:phone] = phones.shift
            hash[:info] = phones.join(', ')
            hash[:external_id] = u[:inn]
            hash[:file_id] = id
            array2 << hash
          end
        end
      end
    end
    array2.each_slice(BATCH_SIZE) { |slice| CsvUser.insert_all(slice) }
    { count: array2.size, data: array2 }
  end

  def enrichment_xlsx
    id = params[:id]
    array = CsvUser.where(file_id: id).to_a
      .uniq { |x| [x.last_name, x.first_name, x.middle_name, x.external_id] }
      .filter { |x| x.phone&.size == 10 || x.info.split(',').filter { |y| y&.size == 10 }.present? }
    array = array.map do |x|
      phone1 = x.phone.size == 10 && x.phone[0] == '9' ? [x.phone] : []
      phone2 = x.info.split(',').filter { |y| y&.size == 10 && y&.first == '9' }
      phone = (phone1 + phone2).join(', ')
      { external_id: x.external_id, phone: phone, last_name: x.last_name, first_name: x.first_name, middle_name: x.middle_name, birth_date: x.birth_date } if phone.present?
    end.compact

    return if array.blank?

    workbook = ::FastExcel.open
    worksheet = workbook.add_worksheet('ФИО_ИНН_ТЕЛ_ДР')
    bold = workbook.bold_format
    headers = array.first.keys
    headers.each_index { |i| worksheet.set_column_width(i, 15) }
    worksheet.append_row(headers, bold)
    array.each { |d| worksheet.append_row(d.values) }
    workbook.close
    send_data(workbook.read_string, filename: "ФИО_ИНН_ТЕЛ_ДР_#{array.size}.xlsx")
  end

  def cards
    filename = Rails.root.join('tmp', 'parser', '[info] spasibosberbank.ru 02.2022.csv')
    array = []
    File.readlines(filename, chomp: true).each do |line|
      next if line == "День\tМесяц\tГод\tТелефон\tEmail\tИнформация"

      z = line.split("\t")
      to_arr(z[5]).each do |card|
        array << {
          phone: z[3],
          email: z[4],
          birthday: to_dt(z),
          card: card
        }
      end
      if array.size >= BATCH_SIZE
        Card.insert_all(array)
        array = []
      end
    end
    Card.insert_all(array) if array.present?
  end

  def cards2
    person_service = PersonService.instance
    filename = Rails.root.join('tmp', 'parser', '[info] spasibosberbank.ru 02.2022.csv')
    array = []
    File.readlines(filename, chomp: true).each do |line|
      next if line == "День\tМесяц\tГод\tТелефон\tEmail\tИнформация"

      z = line.split("\t")
      resp = person_service.search(phone: z[3])
      next if resp['count'] == 0

      last_name, first_name, middle_name = ddd(resp['data'])
      array << Card.where(phone: z[3], birthday: to_dt(z))
                   .map { |card| { id: card.id, last_name: last_name, first_name: first_name, middle_name: middle_name } } if last_name.present?
      if array.size >= BATCH_SIZE
        Card.upsert_all(array, update_only: %i[last_name first_name middle_name])
        array = []
      end
    end
    Card.upsert_all(array, update_only: %i[last_name first_name middle_name]) if array.present?
  end

  private

  def ddd(data)
    element = data.select { |x| x['ИМЯ'] && x['ТЕЛЕФОН'] && x['ДАТА РОЖДЕНИЯ'] }
                  .map { |x| { name: x['ИМЯ'], phone: x['ТЕЛЕФОН'], year: x['ДАТА РОЖДЕНИЯ'].to_date.year } }
                  .compact
                  .uniq
                  .find { |x| x[:year] == z[2].to_i }
                  .first
    element&.dig(:name)&.split(' ')
  rescue StandardError => e
    puts "-------------------------------------------------------------------"
    puts e
  end

  def to_arr(z)
    z.split("{\"Связанные банковские карты\": \"")[1].split("\"")[0].split(";")
  rescue StandardError => e
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts e
    []
  end

  def to_dt(z)
    "#{z[0]}.#{z[1]}.#{z[2]}"&.to_date&.strftime('%d.%m.%Y')
  rescue StandardError => e
    puts "==================================================================="
    puts z[0..2]
    puts e
  end

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
