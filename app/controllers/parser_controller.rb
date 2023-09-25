# frozen_string_literal: true

class ParserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?, except: %i[index show]

  FIELDS = %w[external_id phone passport last_name first_name middle_name birth_date is_phone_verified? is_passport_verified? phone_score].freeze

  def index
    @csv_parsers = CsvParser.all.order(:id)
    @blobs = ActiveStorage::Blob.where(id: @csv_parsers.map(&:file_id))
  end

  def show
    @csv_user = CsvUser.new
    @csv_parser = CsvParser.find_by(file_id: params[:id])
    @csv_parser_logs = @csv_parser.csv_parser_logs.order(id: :desc)
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
    id = 54
    file = ActiveStorage::Attachment.find_by(id: id)
    hash = {}
    rows = file.open(&:count)
    file.open do |f|
      rows.times do |i|
        line = f.readline.force_encoding('UTF-8').chomp.split(';')
        # score = line[11].tr(',', '.').to_f
        # score.to_s.tr('.', ',')
        hash[line[4].last(10).rjust(10, '0')] = line[11] if line[1] != 'first_name'
      end
    end

    CsvUser.where(file_id: params[:parser_id], phone_score: nil).each_slice(10000) do |slice|
      array = slice.map { |user| { id: user.id, phone_score: hash[user.phone] } }
      CsvUser.upsert_all(array.uniq, update_only: :phone_score)
    end
    # if score > 0 && score <= 0.980532787031913
    #   array << { id: u.id, phone_score: score.to_s.tr('.', ',') }
    # else
    #   errors << { id: line[0], phone: line[1], passport: line[2], error: :wrong_score }
    # end
    # render status: :ok, json: { updated: array_.size, errors: errors }
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
    worksheet = workbook.add_worksheet(name.filename.to_s)
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
