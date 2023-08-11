# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  api :POST, '/okb', 'Проверка ОКБ'
  def create # #{PATH}certmgr -list -store umy     # uroot
    with_error_handling do
      curl = "/opt/cprocsp/bin/amd64/curl -i -X POST -vvv --cert #{ENV['CERT_SHA1_THUMBPRINT']}:#{ENV['CERT_PASSWORD']} --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY"
      hash = { client_id: ENV['OKB_CLIENT_ID'], client_secret: ENV['OKB_CLIENT_SECRET'], grant_type: 'client_credentials', scope: 'openid' }
      auth = parse_json :auth, "#{curl} -H Content-Type:application/x-www-form-urlencoded #{hash_to_str(hash, 'd')}"
      t = Time.now
      json = { applicant: params[:okb], submission: { identifier: t.to_i.to_s, date: t.to_date.to_s, app_date: t.to_date.to_s } }.to_json
      hash = { 'Content-Type:': 'application/json', 'Authorization:Bearer ': auth['access_token'], 'X-Request-Id:': ENV['OKB_CLIENT_SECRET'] }
      parse_json :verify, "#{curl} #{hash_to_str(hash, 'H')} -d '#{json}'"
    end
  end

  private

  def hash_to_str(hash, letter)
    hash.map { |key, value| "-#{letter} \"#{key}#{'=' if letter == 'd'}#{value}\"" }.join(' ')
  end

  def parse_json(method, str)
    url = "#{ENV['OKB_HOST']}#{method}"
    # Rails.logger.info("=========== #{method.capitalize} REQUEST: ============ \n #{str} #{url}")
    s = "{#{`#{str} #{url}`.split('{')[1..].join}"
    # Rails.logger.info("=========== #{method.capitalize} RESPONSE: =========== \n #{s}")
    JSON.parse(s)
  end
end

