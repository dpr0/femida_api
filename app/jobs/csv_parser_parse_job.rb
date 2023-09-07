class CsvParserParseJob < ApplicationJob
  queue_as :default

  def perform(id)
    parser = CsvParser.find_by(file_id: id)
    file = ActiveStorage::Attachment.find_by(id: id)
    array = []
    file.open do |f|
      parser.rows.times do
        str = f.readline.force_encoding('UTF-8').chomp.delete("\"")
        next if str == parser.headers

        line = str.downcase.delete("\"").tr('ё', 'е').split(parser.separator)
        array << {
          file_id: id,
          external_id: (line[parser.external_id]    if parser.external_id),
          middle_name: (line[parser.middle_name]    if parser.middle_name),
          phone:       (line[parser.phone].last(10) if parser.phone),
          passport:    (line[parser.passport]       if parser.passport),
          last_name:   (line[parser.last_name]      if parser.last_name),
          first_name:  (line[parser.first_name]     if parser.first_name),
          is_passport_verified: (line[8] if line[8] == 'TRUE'),
          is_phone_verified: (line[9] if line[9] == 'TRUE'),
          birth_date:  (line[parser.birth_date].to_date&.strftime('%d.%m.%Y') if parser.birth_date)
        }
      end
    end
    array.each_slice(10000) { |slice| CsvUser.insert_all(slice) }
    parser.update(status: 3)
  end
end
