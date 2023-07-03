class RetroJob
  include Sidekiq::Job

  queue_as :default

  def perform()
    array = []
    moneyman_array = []
    # moneyman_array2 = []

    File.readlines(Rails.root.join('tmp', 'narod', 'moneyman_test.csv')).each do |line|
      data = line.force_encoding('windows-1251').encode('utf-8').chomp.delete('"').split(";")
      next if data[0] == 'client_id'
      next unless data[8].present? || data[10].present?

      hash = {
        first_name: data[2],
        middle_name: data[3],
        last_name: data[1],
        phone: data[8],
        passport: data[10]
      }
      moneyman_array << hash
      # moneyman_array2 << hash
      #
      # if moneyman_array2.size == 1000
      #   MoneymanUser.insert_all(moneyman_array2)
      #   moneyman_array2 = []
      # end
    end

    puts "======================================================================="

    dfs = DatesFromString.new
    File.readlines(Rails.root.join('tmp', 'narod', 'femida_retro.csv')).each do |line|
      data = line.chomp.split(',')
      next if data[0] == 'client_id'

      arr = moneyman_array.select { |x| x[:last_name] == data[3] && x[:first_name] == data[1] && x[:middle_name] == data[2] }
      array << {
        first_name: data[1],
        middle_name: data[2],
        last_name: data[3],
        phone: data[4],
        birth_date: dfs.find_date(data[5]).first&.to_date&.strftime('%d.%m.%Y'),
        passport: data[6],
        is_passport_verified: arr.find { |x| x[:passport] == data[6] }.present?,
        is_phone_verified: arr.find { |x| [x[:phone], "7#{x[:phone]}"].include? data[4] }.present?
      }

      byebug
      if array.size == 1000
        FemidaRetroUser.insert_all(array)
        array = []
      end
    end
  end
end
