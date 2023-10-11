class ParserDownloadService
  FIELDS = %w[external_id phone passport last_name first_name middle_name birth_date is_phone_verified? is_passport_verified? is_card_verified? phone_score].freeze

  def initialize(parser_id)
    @scope = CsvUser.where(file_id: parser_id)
    @blob = ActiveStorage::Blob.find(parser_id)
  end

  def xlsx
    workbook = ::FastExcel.open
    worksheet = workbook.add_worksheet(@blob.filename.to_s)
    bold = workbook.bold_format
    headers = FIELDS
    headers.each_index { |i| worksheet.set_column_width(i, 15) }
    worksheet.append_row(headers, bold)
    @scope.all.each { |d| worksheet.append_row(d.slice(*FIELDS).values) }
    workbook.close
    workbook.read_string
  end

  def csv
    CSV.generate do |csv|
      csv << FIELDS
      scope.each { |d| csv << d.slice(*FIELDS).values }
    end
  end

  def xlsx_filename
    "#{@blob.filename}_test_#{@scope.count}.xlsx"
  end

  def csv_filename
    "#{@blob.filename}-#{Time.now.to_i}.csv"
  end
end
