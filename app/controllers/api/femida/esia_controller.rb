# frozen_string_literal: true

class Api::Femida::EsiaController < ApplicationController
  protect_from_forgery with: :null_session

  HOST = 'https://esia.gosuslugi.ru'
  PATH = 'api/public/v2'

  before_action :get_token

  api :GET, "/esia?phone=79991112233&passport=1234567890&email=mail@example.com&inn=111222333444&snils=111222333444&inn=111222333444", 'Проверка ЕСИА'
  def index
    with_error_handling do
      json = {}
      req_id = nil
      hash.each do |key, value|
        z1 = get("/esia-rs/#{PATH}/recovery/find?#{value}&verifyToken=#{@token}", key: key)
        req_id ||= z1['requestId']
        json.merge!( key => (z1['description'] == 'Найдена стандартная/подтвержденная УЗ' && z1['status'] == 2))
        z2 = get("/esia-rs/#{PATH}/recovery/find?#{value}&requestId=#{req_id}", headers: @headers, key: key)
        json.merge!( "#{key}_info" => z2)
      end
      json
    end
  end

  api :GET, "/esia/passport?str=1234567890", 'Проверка по номеру паспорта'
  def passport; get_esia; end

  api :GET, "/esia/phone?str=79991112233", 'Проверка по номеру тел'
  def phone;    get_esia; end

  api :GET, "/esia/email?str=mail@example.com", 'Проверка по email'
  def email;    get_esia; end

  api :GET, "/esia/snils?str=111222333444", 'Проверка по СНИЛС'
  def snils;    get_esia; end

  api :GET, "/esia/inn?str=111222333444", 'Проверка по ИНН'
  def inn
    check_inn(params[:str].to_s)
    get_esia
  rescue Exception => e
    render status: :ok, json: { status: false, error: e.message }
  end

  private

  def get_esia
    (render(status: :ok, json: @resp) and return) if @token.nil?

    with_error_handling do
      resp = get("/esia-rs/#{PATH}/recovery/find?#{hash_action}&verifyToken=#{@token}")
      resp1 = { response: (resp['description'] == 'Найдена стандартная/подтвержденная УЗ' && resp['status'] == 2) }
      resp2 = get("/esia-rs/#{PATH}/recovery/find?#{hash_action}&requestId=#{resp['requestId']}", headers: @headers)
      resp2[:str] == false ? resp1 : resp1.merge(resp2)
    end
  end

  def get_token
    type = get("/captcha/#{PATH}/type")
    headers = { captchaSession: type['captchaSession'] }
    capcha = get("/captcha/#{PATH}/image", headers: headers, parse: false)
    @resp = post_rucaptcha(Base64.encode64(capcha), phrase: 0, regsense: 0, numeric: 0, language: 1)
    return if @resp == ApplicationController::ERROR

    @headers = { 'Content-Type' => 'application/json', 'captchaSession' => type['captchaSession'] }
    @token = JSON.parse(RestClient.post(
      "#{HOST}/captcha/#{PATH}/verify",
      { captchaType: type['captchaType'], answer: @resp.split('|').last }.to_json,
      @headers
    ))['verify_token']
  end

  def search_params
    %i[passport inn snils].map { |key| hash[key] if params[key].present? }.compact.join('&')
  end

  def hash_action
    case params[:action]
    when 'phone'    then "mbt=+7(#{params[:str].last(10)[0..2]})#{params[:str].last(10).last(7)}"
    when 'email'    then    "eml=#{params[:str]}"
    when 'passport' then "serNum=#{params[:str]}"
    when 'inn'      then    "inn=#{params[:str]}"
    when 'snils'    then  "snils=#{params[:str]}"
    end
  end

  def hash
    h = {}
    h[:phone]    = "mbt=+7(#{params[:phone].last(10)[0..2]})#{params[:phone].last(10).last(7)}" if params[:phone]
    h[:email]    =    "eml=#{params[:email]}"                                                   if params[:email]
    h[:passport] = "serNum=#{params[:passport]}"                                                if params[:passport]
    h[:inn]      =    "inn=#{params[:inn]}"                                                     if params[:inn]
    h[:snils]    =  "snils=#{params[:snils]}"                                                   if params[:snils]
    h
  end

  def get(path, headers: {}, parse: true, key: :str)
    puts path
    resp = RestClient.get(HOST + path, headers)
    parse ? JSON.parse(resp) : resp
  rescue RestClient::NotFound, RestClient::BadRequest => e
    { key => false }
  end
end
