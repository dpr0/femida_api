class Med1Job < ApplicationJob
  queue_as :default

  def perform()
    dfs = DatesFromString.new
    array = []

    if false
      File.readlines(Rails.root.join('tmp', 'narod', '1.csv')).each do |line|
        z = line.force_encoding('windows-1251').encode('utf-8').chomp.split('|')
        array << { last_name: z[1]&.downcase,
                   first_name: z[2]&.downcase,
                   middle_name: z[3]&.downcase,
                   birth_date: z[4],
                   address: z[8]&.downcase,
                   phone: z[5] }
      end
    end

    File.readlines(Rails.root.join('tmp', 'info', '1')).each do |line|
      z = line.chomp.split("\t")
      next if z[0] == 'Фамилия' || (z[0].blank? && z[1].blank? && z[2].blank?)

      date = begin
               dfs.find_date("#{z[3]}.#{z[4]}.#{z[5]}").first&.to_date&.strftime('%d.%m.%Y')
             rescue
               ''
             end
      array << {
        last_name: z[0]&.downcase,
        first_name: z[1]&.downcase,
        middle_name: z[2]&.downcase,
        birth_date: date,
        phone: z[6],
        # passport: JSON.parse(z[8])['Документ'],
        # address: z[7]&.downcase
      }
      # if array.size == 2000 || z[6] == '9125330641'
      #   ParsedUser.insert_all(array)
      #   array = []
      # end
    end
    ParsedUser.insert_all(array)
  end
end
