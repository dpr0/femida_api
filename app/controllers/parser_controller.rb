# frozen_string_literal: true

class ParserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  def index
    @csv_parsers = CsvParser.all
  end

  def sample
    user = params['csv_user'].permit!.to_h.reject { |_, value| value.blank? } if params['csv_user'].present?
    @csv_user = CsvUser.new

    @results = user ? PersonService.instance.search(user)['data'].group_by { |x| x['Telephone'] } : {}
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

  def solar_check
    check(CsvParserSolarJob)
  end

  def inn_check
    check(CsvParserInnJob)
  end

  def user_check
    check(CsvParserUserJob)
  end

  def okb_check
    check(CsvParserOkbJob)
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

  def check(job, status: 4)
    id = params[:parser_id]
    CsvParser.find_by(file_id: id).update(status: status)
    job.perform_later(id)
    redirect_to parser_path(id)
  end

  def index_by(key)
    @headers.find_index(params[key])
  end
end
