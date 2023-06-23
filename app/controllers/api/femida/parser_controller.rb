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

  # api :GET, '/phone_rates', 'Пользователи retro_mc_femida_complete_scored - csv'
  def phone_rates
    filename = 'sql1.csv' # 'retro_mc_femida_complete_scored.csv'
    file = File.read(Rails.root.join('tmp', 'parser', filename))
    data = CSV.parse(file, headers: true)
    response = []
    # esia = Api::Femida::EsiaController.new

    data.each_slice(100) do |d|
      # z.rate = d['0'].to_f
      # if z.status.nil? && z.rate >= 0.75
        # esia.send :get_token
        # next if esia.token.nil?
        # str = "mbt=+7(#{d['phone'].last(10)[0..2]})#{d['phone'].last(10).last(7)}"
        # resp = get("/esia-rs/#{"#{esia.class}::PATH".constantize}/recovery/find?#{str}&verifyToken=#{esia.token}", key: :phone)
        # z.status = resp['description']

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
end
