class Med1Job < ApplicationJob
  queue_as :default

  def perform()
    array = []
    File.readlines(Rails.root.join('tmp', 'narod', '6.csv')).each do |line|
      z = line.force_encoding('windows-1251').encode('utf-8').chomp.split('|')
      array << { last_name: z[1]&.downcase,
                 first_name: z[2]&.downcase,
                 middle_name: z[3]&.downcase,
                 birth_date: z[4],
                 address: z[8]&.downcase,
                 phone: z[5] }
      if array.size == 2000
        ParsedUser.insert_all(array)
        array = []
      end
    end
  end
end
