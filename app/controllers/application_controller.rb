# frozen_string_literal: true

class ApplicationController < ActionController::Base
  BATCH_SIZE = 10_000
  RETRY = 30
  URL   = 'http://rucaptcha.com'
  URL2  = 'http://cptch.net'
  KEY1  = 'RUCAPTCHA_KEY'
  KEY2  = 'CPTCH_NET_KEY'
  HOST  = 'https://esia.gosuslugi.ru'
  ERROR = 'ERROR_CAPTCHA_UNSOLVABLE'

  private

  def post_rucaptcha(body, attrs = {})
    params = { key: ENV[KEY1], body: body, method: 'base64' }
    rucaptcha = RestClient.post("#{URL}/in.php", params.merge(attrs))
    id = rucaptcha.body.split('|').last
    x = 0
    resp = get_rucaptcha(id)
    while x < RETRY
      x += 1
      resp = get_rucaptcha(id)
      Rails.logger.info "#{x}: #{resp.body}"
      x = RETRY if resp.body == ERROR
      resp.body[0..1] == 'OK' ? (x = RETRY) : sleep(1.second)
    end
    resp.body
  end

  def get_rucaptcha(id)
    RestClient.get("#{URL}/res.php?key=#{ENV[KEY1]}&action=get&id=#{id}")
  end

  def with_error_handling
    render status: :ok, json: yield
  rescue StandardError => e
    render status: :ok, json: { status: false, error: e.message }
  end

  def get(path, headers: {}, parse: true, key: :str, host: HOST)
    Rails.logger.info host + path
    resp = RestClient.get(host + path, headers)
    parse ? JSON.parse(resp) : resp
  rescue RestClient::NotFound, RestClient::BadRequest => e
    { key => false }
  end

  def is_admin?
    redirect_to '/' unless current_user.admin?
  end

  def is_parser?
    redirect_to '/' unless current_user.user_roles.find { |role| role.role == 'parser' }
  end

  def authenticate_request
    @current_user = User.auth_by_token(request.headers)
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
