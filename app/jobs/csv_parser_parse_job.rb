class CsvParserParseJob < ApplicationJob
  queue_as :default

  def perform(hash)
    id = hash[:id]
    parser = CsvParser.find_by(file_id: id)
    file = ActiveStorage::Attachment.find_by(id: id)
    array = []
    file.open do |f|
      parser.rows.times do
        encoding = hash[:encoding] || 'utf-8'
        str = f.readline.force_encoding(encoding).encode('utf-8').chomp.delete("\"")
        next if str == parser.headers || str.blank?

        line = str.downcase.delete("\"").tr('ё', 'е').split(parser.separator)
        next if line.include? 'last_name'

        if parser.birth_date
          str2 = line[parser.birth_date]
          birth_date = parser.date_mask.present? ? Date.strptime(str2, parser.date_mask) : str2&.to_date
        end
        array << {
          file_id:      id,
          birth_date:  (birth_date.strftime('%d.%m.%Y') if parser.birth_date),
          external_id: (line[parser.external_id]    if parser.external_id),
          phone:       (line[parser.phone].last(10) if parser.phone),
          passport:    (line[parser.passport]       if parser.passport),
          last_name:   (line[parser.last_name]      if parser.last_name),
          first_name:  (line[parser.first_name]     if parser.first_name),
          middle_name: (line[parser.middle_name]    if parser.middle_name),
          info:        (line[parser.info]           if parser.info),
          is_phone_verified:    (line[7] if line[7] == 'true'),
          is_passport_verified: (line[8] if line[8] == 'true')
        }
      end
    end
    array.each_slice(ApplicationController::BATCH_SIZE) { |slice| CsvUser.insert_all(slice) }
    parser.update(status: 3)
  end
end
