# frozen_string_literal: true

class Api::Femida::NalogController < ApplicationController
  protect_from_forgery with: :null_session

  HOST = 'https://pb.nalog.ru/'
  RETRY = 5

  api :GET, '/nalog/ogr?id=:inn', 'Проверка на ограничение' # 668608997290
  def ogr
    with_error_handling do
      inn = check_inn(params[:id])
      hash = captcha_proc
      hash[:mode] = 'search-ogr'
      hash[:queryOgr] = inn
      d = search_proc(hash)
      data = d['ogrfl']['data'] + d['ogrul']['data']
      # { data: data, company: company_proc(data) }
      {
        success: true, error: '',
        limit_org: data.map do |d|
          {
            name: d['ogr_name'],
            inn: d['ogr_inn'],
            position: d['rel'],
            reason: d['ogr'],
            start_date: d['dtstart'],
            end_date: d['dtend'],
            org_name: d['ul_name'],
            org_inn: d['ul_inn']
          }
        end
      }
    end
  end

  api :GET, '/nalog/uchr?id=:inn', 'Проверка на учредителей и гендиректоров' # 502419236001
  def uchr
    with_error_handling do
      inn = check_inn(params[:id])
      hash = captcha_proc
      hash[:mode] = 'search-upr-uchr'
      hash[:queryUpr] = inn
      hash[:uprType0] = 1
      hash[:uprType1] = 1
      data = search_proc(hash)
      # resp = data.map do |z|
      #   hash = { pbCaptchaToken: hash[:pbCaptchaToken], token: z['token'], mode: 'search-ul', queryUpr: z['inn'] }
      #   x = search_proc(hash)
      #   next unless x
      #
      #   x['ul']['data']
      # end.compact.flatten
      # { data: data, resp: resp, company: company_proc(resp, hash[:pbCaptchaToken]) }
      {
        success: true, error: '',
        director: data['upr']['data'].map do |d|
          { inn: d['inn'], name: d['name'], count: d['ul_cnt'] }
        end,
        owner: data['uchr']['data'].map do |d|
          { inn: d['inn'], name: d['name'], count: d['ul_cnt'] }
        end
      }
    end
  end

  api :GET, '/nalog/ip?id=:inn', 'Проверка на ИП' # 772830410106
  def ip
    with_error_handling do
      inn = check_inn(params[:id])
      hash = captcha_proc
      hash[:mode] = 'search-ip'
      hash[:queryIp] = inn
      hash[:uprType0] = 1
      hash[:uprType1] = 1
      data = search_proc(hash)['ip']['data']
      # { data: data, company: company_proc(data) }
      {
        success: true, error: '',
        ip: data.map do |d|
          { ogrn: d['ogrn'], okved: d['okved2'], okved_name: d['okved2name'], name: d['namec'] }
        end
      }
    end
  end

  api :GET, '/nalog/rdl?fio=:fio&birthday=31.12.1999', 'Проверка на дисквалификацию'
  def rdl
    with_error_handling do
      hash = captcha_proc
      hash[:mode] = 'search-rdl'
      hash[:queryRdl] = params[:fio]
      hash[:dateRdl] = params[:birthday]
      hash[:uprType0] = 1
      hash[:uprType1] = 1
      data = search_proc(hash)['rdl']['data']
      # { data: data }
      {
        success: true, error: '',
        dis: data.map do |d|
          {
            number: d['nomzap'],
            name: d['namefl'],
            date_of_birth: d['datarozhd'],
            place_of_birth: d['mestorozhd'],
            name_org: d['naimorg'],
            position: d['dolzhnost'],
            article: d['svednarush'],
            creator: "#{d['dolzhnsud']} #{d['namesud']}",
            court: d['naimorgprot'],
            period: d['diskvsr'],
            start_date: d['datanachdiskv'],
            end_date: d['datakondiskv']
          }
        end
      }
    end
  end

  private

  def company_proc(array, pb = nil)
    array.map do |z|
      hash = { token: z['token'], method: 'get-request' }
      hash[:pbCaptchaToken] = pb if pb
      x = load_retry(:company, hash)
      next if x.nil?

      hash = { token: x['token'], id: x['id'], method: 'get-response' }
      load_retry(:company, hash)
    end.compact
  end

  def search_proc(hash)
    hash[:ogrFl] = 1
    hash[:ogrUl] = 1
    load_retry(:search, hash)
  end

  def captcha_proc
    z = RestClient.get("#{HOST}static/captcha.bin?version=2").body
    captcha = RestClient.get("#{HOST}static/captcha.bin?version=2&a=#{z}")
    @resp = post_rucaptcha(Base64.encode64(captcha.body), phrase: 0, regsense: 0, numeric: 1, language: 0)
    return if @resp == ApplicationController::ERROR

    captcha = load_retry(:captcha, { captcha: @resp.split('|').last, captchaToken: z })
    { pbCaptchaToken: captcha, token: z }
  end

  def load_retry(url, hash)
    puts "--------------------------------------------------------- => #{url}"
    puts hash

    x = 0
    resp = nil
    while x < RETRY
      x += 1
      resp = load(url, hash)
      resp.nil? ? sleep(1.second) : (x = RETRY)
    end
    puts "\n <= ..... #{resp}"
    JSON.parse(resp) if resp.present?
  end

  def load(url, hash = {})
    RestClient::Request.execute(
      url: "#{HOST}#{url}-proc.json",
      payload: hash.map { |key, value| "#{key}=#{value}" }.join("&"),
      method: :post,
      verify_ssl: false
    ).body
    rescue Errno::ECONNRESET, RestClient::BadRequest
  end
end
