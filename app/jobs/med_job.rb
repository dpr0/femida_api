class MedJob < ApplicationJob
  queue_as :default

  def perform()
    array = []
    File.readlines(Rails.root.join('tmp', 'parser', '.csv')).each do |line|
      z = line.chomp.delete('"').split(',')
      next if z[1] == 'surname'

      hash = name_from(z)
      array << hash.merge(
        birth_date: to_dt(z[9]),
        passport: z[7].present? ? z[7] : z[-1],
        phone: to_phone(z[6]) || to_phone(z[5]),
        address: z[4]
      )
      if array.size == 20_000
        ParsedUser.insert_all(array)
        array = []
      end
    end
    ParsedUser.insert_all(array)
  end

  private

  def name_from(z)
    z1, z2, z3  = z[12]&.split(' ')
    last_name   = (z[1].present? ? z[1] : z1)&.downcase&.tr('ё', 'е')
    first_name  = (z[2].present? ? z[2] : z2)&.downcase&.tr('ё', 'е')
    middle_name = (z[3].present? ? z[3] : z3)&.downcase&.tr('ё', 'е')
    { last_name: last_name, first_name: first_name, middle_name: middle_name }
  end

  def to_dt(dt)
    date = dt.to_date
    return if date.year < 1900

    (date + 1.day).strftime('%d.%m.%Y')
  rescue
  end

  def to_phone(str)
    phone = str.scan(/\d/).join.last(10)
    phone if phone.present?
  rescue
  end
end
