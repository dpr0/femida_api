# frozen_string_literal: true

class ParserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  def index
  end

  def show
    @csv_parser = CsvParser.find_by(file_id: params[:id])
    @csv_user = CsvUser.new
    @csv_users = CsvUser.where(file_id: params[:id]).all
    @headers = @csv_parser.headers.split(@csv_parser.separator)
  end

  def create
    current_user.attachments.attach(params[:user][:attachment])
    file = current_user.attachments.last
    headers = file.open(&:first).chomp
    rows = file.open(&:count) - 1
    a1 = headers.split(';').size
    a2 = headers.split(',').size
    sep = [' ',';',','][a1 <=> a2]
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
    CsvParserParseJob.perform_later(params[:parser_id])
    redirect_to parser_path(params[:parser_id])
  end

  def solar_check
    CsvParserSolarJob.perform_later(params[:parser_id])
    redirect_to parser_path(params[:parser_id])
  end

  def inn_check
    CsvParserInnJob.perform_later(params[:parser_id])
    redirect_to parser_path(params[:parser_id])
  end

  def okb_check
    CsvParserOkbJob.perform_later(params[:parser_id])
    redirect_to parser_path(params[:parser_id])
  end

  def get_csv
    z = CSV.generate do |csv|
      csv << %w[external_id phone passport last_name first_name middle_name birth_date is_phone_verified is_passport_verified]
      CsvUser.where(file_id: params[:parser_id]).each do |d|
        csv << [d.external_id, d.phone, d.passport, d.last_name, d.first_name, d.middle_name, d.birth_date, d.is_phone_verified, d.is_passport_verified]
      end
    end
    send_data(z, filename: "response_ID_#{params[:parser_id]}-#{Time.now.to_i}.csv", type: 'text/csv')
  end

  private

  def index_by(key)
    @headers.find_index(params[key])
  end
end
