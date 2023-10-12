# frozen_string_literal: true

class ParserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?
  before_action :is_parser?, except: %i[index show edit create update download]
  before_action :load_csv_parser, only: %i[show edit]

  def index
    @csv_parsers = CsvParser.all.order(id: :desc)
    @blobs = ActiveStorage::Blob.where(id: @csv_parsers.map(&:file_id))
  end

  def show
    @csv_parser_logs = @csv_parser.csv_parser_logs.order(id: :desc)
    @csv_users = @csv_parser.csv_users
  end

  def edit
    @csv_user = CsvUser.new
    @headers = @csv_parser.headers.split(@csv_parser.separator)
  end

  def create
    redirect_to parser_index_path and return if params.dig(:user, :attachment).blank?

    current_user.attachments.attach(params[:user][:attachment])
    file = current_user.attachments.last
    headers = file.open(&:first).chomp
    size = ->(s) { headers.split(s).size }
    sep = [' ', ';', ','][size.(';') <=> size.(',')]
    CsvParser.create(file_id: file.id, headers: headers, rows: file.open(&:count), separator: sep)
    redirect_to edit_parser_path(file.id)
  end

  def update
    csv_parser = CsvParser.find_by(file_id: params[:id])
    @headers = csv_parser.headers.split(csv_parser.separator)
    csv_parser.update(
      status:      2,
      info:        index_by(:info),
      phone:       index_by(:phone),
      passport:    index_by(:passport),
      last_name:   index_by(:last_name),
      first_name:  index_by(:first_name),
      middle_name: index_by(:middle_name),
      birth_date:  index_by(:birth_date),
      external_id: index_by(:external_id),
      date_mask:   params[:date_mask]
    )
    CsvParserParseJob.perform_later(id: params[:id], limit: params[:limit] || 100, encoding: params[:encoding])
    redirect_to parser_path(csv_parser.file_id)
  end

  def start
    array = []
    array += [CsvParserDbOkbJob, CsvParserUserJob, CsvParserSolarPhoneJob] if params[:check1] == '1'
    array += [CsvParserSolarPasspJob, CsvParserInnJob]                     if params[:check2] == '1'
    array += [CsvParserCardJob]                                            if params[:check3] == '1'
    array += [CsvParserOkbJob]                                             if params[:check4] == '1'
    array += [CsvParserScoreJob]                                           if params[:check5] == '1'
    check(array)
  end

  def download
    service = ParserDownloadService.new(params[:parser_id])
    send_data(service.send(params[:format]), filename: service.send("#{params[:format]}_filename"))
  end

  private

  def check(jobs = [], status: 4)
    id = params[:parser_id]
    CsvParser.find_by(file_id: id).update(status: status)
    hash = { id: id, limit: params[:limit] || 100 }
    hash[:encoding] = params[:encoding] if params[:encoding]
    [jobs].flatten.each { |job| job.perform_async(hash) }
    redirect_to parser_path(id)
  end

  def index_by(key)
    @headers.find_index(params[key])
  end

  def load_csv_parser
    @csv_parser = CsvParser.find_by(file_id: params[:id])
  end
end
