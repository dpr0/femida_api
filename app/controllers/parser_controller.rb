# frozen_string_literal: true

class ParserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?, except: %i[index show]

  FIELDS = %w[external_id phone passport last_name first_name middle_name birth_date is_phone_verified? is_passport_verified? phone_score]

  def index
    @csv_parsers = CsvParser.all.order(:id)
    @blobs = ActiveStorage::Blob.where(id: @csv_parsers.map { |x| x.file_id })
  end

  def show
    @csv_user = CsvUser.new
    @csv_parser = CsvParser.find_by(file_id: params[:id])
    @csv_users = @csv_parser.csv_users
    @headers = @csv_parser.headers.split(@csv_parser.separator)
  end

  def create
    current_user.attachments.attach(params[:user][:attachment])
    file = current_user.attachments.last
    headers = file.open(&:first).chomp
    rows = file.open(&:count)
    a1 = headers.split(';').size
    a2 = headers.split(',').size
    sep = [' ', ';', ','][a1 <=> a2]
    CsvParser.create(file_id: file.id, headers: headers, rows: rows, separator: sep)
    redirect_to parser_path(file.id)
  end

  def update
    csv_parser = CsvParser.find_by(file_id: params[:id])
    @headers = csv_parser.headers.split(csv_parser.separator)
    csv_parser.update(
      status:      1,
      phone:       index_by(:phone),
      passport:    index_by(:passport),
      last_name:   index_by(:last_name),
      first_name:  index_by(:first_name),
      middle_name: index_by(:middle_name),
      birth_date:  index_by(:birth_date),
      external_id: index_by(:external_id)
    )
    redirect_to parser_path(csv_parser.file_id)
  end

  def parse
    check(CsvParserParseJob, status: 2)
  end

  def solar_phone_check
    check(CsvParserSolarPhoneJob)
  end

  def solar_passp_check
    check(CsvParserSolarPasspJob)
  end

  def inn_check
    check(CsvParserInnJob)
  end

  def user_check
    check(CsvParserUserJob)
  end

  def db_okb_check
    check(CsvParserDbOkbJob)
  end

  def okb_check
    check(CsvParserOkbJob)
  end

  def xxx_check
    check(CsvParserXxxJob)
  end

  def add_score
    errors = []
    array = []
    file = ActiveStorage::Attachment.find_by(id: 23)
    csv_users = CsvUser.where(file_id: params[:parser_id]).to_a

    file.open do |f|
      (csv_users.size + 1).times do|i|
        line = f.readline.force_encoding('UTF-8').chomp.split(';')
        next if line[0] == 'external_id' || line[0].blank?

        u = csv_users.find { |u| u.phone == line[1] && u.passport == line[2].rjust(10, '0') }
        if line[9].present? && u.present?
          score = line[9].tr(',','.').to_f
          Rails.logger.info i
          if score > 0 && score <= 0.980532787031913
            array << { id: u.id, phone_score: score }
          else
            errors << { id: u.id, phone: line[1], passport: line[2], error: :wrong_score }
          end
        else
          errors << { id: u.id, phone: line[1], passport: line[2], error: :empty_score }
        end
      end
    end
    array.each_slice(10000) { |slice| CsvUser.upsert_all(slice, update_only: :phone_score) }
    { updated: array.size, errors: errors }
  end

  def get_csv
    data = CSV.generate do |csv|
      csv << FIELDS
      CsvUser.where(file_id: params[:parser_id]).each { |d| csv << d.slice(*FIELDS).values }
    end
    send_data(data, filename: "#{ActiveStorage::Blob.find(params[:parser_id]).filename}-#{Time.now.to_i}.csv", type: 'text/csv')
  end

  def get_xlsx
    scope = CsvUser.where(file_id: params[:parser_id])
    name = ActiveStorage::Blob.find(params[:parser_id])
    workbook = ::FastExcel.open
    worksheet = workbook.add_worksheet("#{name.filename}")
    bold = workbook.bold_format
    headers = FIELDS
    headers.each_index { |i| worksheet.set_column_width(i, 15) }
    worksheet.append_row(headers, bold)
    scope.all.each { |d| worksheet.append_row(d.slice(*FIELDS).values) }
    workbook.close
    send_data(workbook.read_string, filename: "#{name.filename}_test_#{scope.count}.xlsx")
  end

  private

  def check(job, status: 4)
    id = params[:parser_id]
    CsvParser.find_by(file_id: id).update(status: status)
    job.perform_later(id: id, limit: params[:limit] || 100)
    redirect_to parser_path(id)
  end

  def index_by(key)
    @headers.find_index(params[key])
  end
end
