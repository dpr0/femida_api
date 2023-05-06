# frozen_string_literal: true

class Api::Femida::OpendataController < ApplicationController
  protect_from_forgery with: :null_session

  SIZE = 30_000
  URL1 = 'https://rkn.gov.ru/opendata/7705846236-'
  URL2 = 'https://fsrar.gov.ru/opendata/7710747640-'
  URL3 = 'https://rosstat.gov.ru/opendata/7708234640-'
  URL4 = 'https://opendata.fssp.gov.ru/7709576929-'
  URL5 = 'https://customs.gov.ru/opendata/7730176610-'
  URL6 = 'https://nalog.gov.ru/opendata/7707329152-'
  URLS = {
    'rkn2'        => 'LicComm',
    'rkn3'        => 'ResolutionSMI',
    'rkn5'        => 'SignificantTelecomOperators',
    'rkn6'        => 'OperatorsPD',
    'rkn10'       => 'BorderTelecommunications',
    'rkn13'       => 'InspectionPlan',
    'rkn14'       => 'AuditsResults',
    'rkn18'       => 'AccreditedExpertsMassCommunications',
    'rkn20'       => 'InformationDistributor',
    'rkn26'       => 'NewsAgregator',
    'fsrar'       => 'reestr',
    'rosstat2018' => '7708234640bdboo2018',
    'rosstat2017' => 'bdboo2017',
    'rosstat2016' => 'bdboo2016',
    'rosstat2015' => 'bdboo2015',
    'rosstat2014' => 'bdboo2014',
    'rosstat2013' => 'bdboo2013',
    'rosstat2012' => 'bdboo2012',
    'fssp6'       => 'iplegallist',
    'fssp7'       => 'iplegallistcomplete',
    'customs92'   => 'vvozavtoru',
    'nalog72'     => 'snr',
    'nalog73'     => 'kgn',
    'nalog76'     => 'paytax',
    'nalog77'     => 'debtam',
    'nalog78'     => 'taxoffence',
    'nalog86'     => 'rsmp',
    'nalog27'     => 'disqualifiedpersons', # TODO
  }.freeze

  api :GET, '/opendata', 'opendata'
  def index
    URLS.each do |key, value|
      filename = get_filename(key, select_url(key) + value)
      opendata = Opendata.find_by(number: key, deleted_at: nil)
      if opendata
        if opendata.filename == filename
        else
          opendata.deleted_at = Time.current
          opendata.save
          Opendata.create(number: key, status: :new, filename: filename)
        end
      else
        Opendata.create(number: key, status: :new, filename: filename)
      end
    end
    opendatas = Opendata.all.order(id: :desc)
    @opendata = opendatas.select { |r| r.deleted_at.nil? }
    @opendata_deleted = opendatas.select { |r| r.deleted_at.present? }
  end

  api :GET, '/opendata/:id', 'opendata'
  def show
    render status: :not_found, json: { status: :not_found } and return if URLS[params[:id]].nil?

    size = 0
    time = Time.now
    @klass = "Opendata::#{params[:id].capitalize}".constantize
    @opendata = @klass.new.attributes.to_h
    @opendata.delete('id')
    opendata = Opendata.find_by(number: params[:id], deleted_at: nil)
    render status: :ok, json: { status: :already_finished } and return if opendata.status == 'finished'

    url = select_url(params[:id]) + URLS[params[:id]]
    filename = opendata.filename || get_filename(params[:id], url)
    opendata.update(status: :started)
    ActiveRecord::Base.connection.execute("TRUNCATE opendata_#{params[:id]}")
    file = get(filename)

    case filename.split('.').last
    when 'xml'
      size = parse(file, stream: false)
    when 'csv'
      size = parse_csv_file(file, stream: false)
    when 'zip'
      path = Tempfile.new(['file', '.zip']).path
      File.binwrite(path, file)
      Zip::File.open(path) do |zip_file|
        size = zip_file.sum do |entry|
          next if entry.size == 0

          case params[:id]
          when 'rkn6'     then parse_by_line(entry)
          when /^fsrar/   then parse_by_line(entry, 'row')
          when /^rosstat/ then parse_csv_file(entry)
          when /^rkn/     then parse(entry)
          when /^customs/ then parse_csv_file(entry)
          when /^nalog/   then parse_by_line(entry, 'Документ')
          else parse(entry)
          end
        end
      end
    else
      size
    end
    opendata.update(status: :finished, rows: size)

    render status: :ok, json: { time: (Time.now - time), size: size }
  end

  private

  def parse_csv_file(file, stream: true)
    array = []
    if stream
      file.get_input_stream.each("\n") do |row|
        z = row.force_encoding('windows-1251').chomp.split(";")
        array << { name: z[0], okpo: z[1], okopf: z[2], okfs: z[3], okved: z[4], inn: z[5], measure: z[6], type: z[7] }
      end
    else
      file.body.each_line do |row|
        # z = CSV.parse(row)[0]
        z = row.chomp.force_encoding('windows-1251').split(";")
        z.shift if @klass.name == 'Opendata::Customs92'
        hash = @opendata.dup
        hash.keys.each_with_index { |name, index| hash[name] = z[index] }
        array << hash
      end
    end
    array.shift
    insert(array)
    array.size
  end

  def get(url)
    RestClient::Request.execute(url: url, method: :get, verify_ssl: false)
  end

  def get_filename(id, url)
    parsed_data = Nokogiri::HTML.parse(get(url))
    z = case id
    when  /^fsrar/
      parsed_data.css('table.sticky-enabled tr')[1..].map { |x| { key: x.children[0].text, value: x.children[1].text } }
    when /^rosstat/
      parsed_data.css('table tr')[1..].map { |x| { key: x.children[3].text, value: url + '/' + x.children[5].text.delete("\r\n\t\s") } }
    when /^fssp/
      parsed_data.css('table.b-table tr')[1..].map { |x| { key: x.children[3].text, value: url + '/' + x.children[5].text.delete("\r\n\t\s") } if x.children[5] }
    when /^rkn/
      parsed_data.css('table.TblList tr')[1..].map { |x| { key: x.children[3].text, value: url + '/' + x.children[5].text.delete("\r\n\t\s") } }
    when /^customs/
      parsed_data.css('table tr')[1..].map { |x| { key: x.children[3].text, value: url.sub('opendata', 'storage/opendata') + '/' + x.children[5].text.delete("\r\n\t\s") } }
    when /^nalog/
      parsed_data.css('table tr')[1..].map { |x| { key: x.children[3].text, value: x.children[5].text.delete("\r\n\t\s")  } }
    else
      parsed_data.css('table tr')[1..].map { |x| { key: x.children[3].text, value: x.children[5].text.delete("\r\n\t\s")  } }
    end.compact
    z.find { |x| x[:key] =~ /(URL)/ }[:value]
  end

  def parse(entry, stream: true)
    array = []
    Nokogiri::XML.parse(stream ? entry.get_input_stream.read : entry)
                 .xpath("//rkn:register/rkn:#{params[:id] == 'rkn18' ? 'expert' : 'record'}").each do |x|
      hash = @opendata.dup
      x.children.each { |ch| hash[ch.name] = ch.text.chomp if @opendata.keys.include?(ch.name) }
      array << hash
    end
    insert(array)
    array.size
  end

  def parse_by_line(entry, attr = 'rkn:record')
    array = []
    size = 0
    entry.get_input_stream.each("</#{attr}>") do |raw_line|
      record = "<#{attr}>" + raw_line.split("<#{attr}").last.delete("\r\n\t")
      hash = @opendata.dup
      attrs = Nokogiri::XML.parse(record).children[0].children
      array << (attr == 'rkn:record' ? attrs_record(attrs, hash) : attrs_row(attrs, hash))
      if array.size == SIZE
        insert(array)
        array = []
        size += 1
      end
    end
    size * SIZE + array.size
  end

  def attrs_record(attrs, hash)
    attrs.each do |ch|
      name = ch.name.split(':').last
      hash[name] = ch.text.chomp if @opendata.keys.include?(name)
    end
    hash
  end

  def attrs_row(attrs, hash)
    @opendata.keys.each_with_index { |name, index| hash.send :'[]=', name, attrs[index+1]&.text }
    hash
  end

  def insert(array)
    array.each_slice(SIZE) { |slice| @klass.insert_all(slice) }
  end

  def select_url(key)
    case key
    when /^rkn/     then URL1
    when /^fsrar/   then URL2
    when /^rosstat/ then URL3
    when /^fssp/    then URL4
    when /^customs/ then URL5
    when /^nalog/   then URL6
    else                 URL1
    end
  end
end
