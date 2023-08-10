# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  PATH = '/opt/cprocsp/bin/amd64/'

  api :GET, '/okb/:id', "Проверка ОКБ"
  def show
    # with_error_handling do
      # #{PATH}certmgr -list -store umy
      # #{PATH}certmgr -list -store uroot
    curl = "#{PATH}curl -i -X POST -vvv --cert #{ENV['CERT_SHA1_THUMBPRINT']}:#{ENV['CERT_PASSWORD']} \\
            --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY"
    Rails.logger.info('curl:')
    Rails.logger.info(curl)

    hash = {
      client_id:      ENV['OKB_CLIENT_ID'],
      client_secret:  ENV['OKB_CLIENT_SECRET'],
      grant_type:    'client_credentials',
      scope:         'openid'
    }

    Rails.logger.info('hash_map:')
    Rails.logger.info(hash.map { |key, value| "-d #{key}=#{value} \\" }.join(' '))

    auth = parse_json `#{curl} -H Content-Type:application/x-www-form-urlencoded \\
      #{hash.map { |key, value| "-d #{key}=#{value} \\" }.join(' ')} #{ENV['OKB_HOST']}auth`

    json = {
      submission: {
        identifier: '1',
        date: '2022-12-18',
        app_date: '2022-12-18'
      },
      applicant: {
        name: 'ХАНТЕР',
        surname: 'ХАНТЕР',
        patronymic: 'ХАНТЕР',
        birthday: '1988-01-09',
        consent: 'Y',
        document: 1655054567,
        issued_at: '2022-01-23',
        telephone_number: '+79031234567'
      }
    }.to_json
    Rails.logger.info('json:')
    Rails.logger.info(json)

    resp = parse_json `#{curl} -H Content-Type:application/json \\
      -H "Authorization:Bearer #{auth['access_token']}" \\
      -H "X-Request-Id:#{ENV['OKB_CLIENT_SECRET']}" \\
      -d '#{json}' \\
      #{ENV['OKB_HOST']}verify
    `
    render status: :ok, json: resp
    # end
  end

  private

  def parse_json(str)
    Rails.logger.info(str)
    JSON.parse(str.split("r\n\r\n").last)
  end
end
