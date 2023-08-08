class MedJob < ApplicationJob
  queue_as :default

  def perform()
    array = []
    File.readlines(Rails.root.join('tmp', 'narod', 'med.txt')).each do |line|
      z = line.chomp.split("\t")
      name = z.first.split(' ')
      array << { last_name: name[0],
                 first_name: name[1],
                 middle_name: name[2],
                 birth_date: z[1],
                 passport: z[3],
                 phone: z[4],
                 address: z[5] }
      if array.size == 1000
        ParsedUser.insert_all(array)
        array = []
      end
    end
  end
end
