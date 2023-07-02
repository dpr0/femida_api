class RetroJob < ApplicationJob
  queue_as :default

  def perform()
    array = []
    moneyman_array = []

    File.readlines(Rails.root.join('tmp', 'narod', 'moneyman_fios_complete.csv')).each do |line|
      data = line.force_encoding('windows-1251').encode('utf-8').chomp.delete('"').split(";")
      next if data[0] == 'client_id'
      next unless data[8].present? || data[10].present?

      moneyman_array << {
        fio: "#{data[1]} #{data[2]} #{data[3]}",
        # f: data[1],
        # i: data[2],
        # o: data[3],
        # bd: "#{data[4]}.#{data[5]}.#{data[6]}",
        phone: data[8],
        pasp: data[10]
      }
    end

    puts "======================================================================="
    puts "moneyman_array size #{moneyman_array.size}"
    puts "start FemidaRetroUser"
    dfs = DatesFromString.new
    File.readlines(Rails.root.join('tmp', 'narod', 'femida_retro.csv')).each do |line|
      data = line.chomp.split(',')
      next if data[0] == 'client_id'

      arr = moneyman_array.select { |x| x[:fio] == "#{data[3]} #{data[1]} #{data[2]}" }
      array << {
        first_name: data[1],
        middle_name: data[2],
        last_name: data[3],
        phone: data[4],
        birth_date: dfs.find_date(data[5]).first&.to_date&.strftime('%d.%m.%Y'),
        passport: data[6],
        is_passport_verified: arr.find { |x| x[:pasp] == data[6] }.present?,
        is_phone_verified: arr.find { |x| [x[:phone], "7#{x[:phone]}"].include? data[4] }.present?
      }
      if array.size == 1000
        FemidaRetroUser.insert_all(array)
        array = []
      end
    end
  end
end
