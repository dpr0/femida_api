# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  PATH = '/opt/cprocsp/bin/amd64/'

  api :GET, '/okb/:id', "Проверка ОКБ"
  def show
    # with_error_handling do
      # #{PATH}certmgr -list -store umy
      # #{PATH}certmgr -list -store uroot
    curl = "#{PATH}curl -i -X POST -vvv --cert #{ENV['CERT_SHA1_THUMBPRINT']}:#{ENV['CERT_PASSWORD']} --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY"
    hash = {
      client_id:      ENV['OKB_CLIENT_ID'],
      client_secret:  ENV['OKB_CLIENT_SECRET'],
      grant_type:    'client_credentials',
      scope:         'openid'
    }
    str = "#{curl} -H Content-Type:application/x-www-form-urlencoded #{hash_to_str(hash, 'd')} #{ENV['OKB_HOST']}auth"
    Rails.logger.info('========================================')
    Rails.logger.info(str)
    auth = parse_json `#{str}`.split("<").last

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
    hash = {
      'Content-Type:': 'application/json',
      'Authorization:Bearer ': auth['access_token'],
      'X-Request-Id:': ENV['OKB_CLIENT_SECRET']
    }

    str = "#{curl} #{hash_to_str(hash, 'H')} -d '#{json}' #{ENV['OKB_HOST']}verify"
    Rails.logger.info('========================================')
    Rails.logger.info(str)
    resp = parse_json `#{str}`.split("\n\n").last
    render status: :ok, json: resp
    # end
  end

  private

  def hash_to_str(hash, letter)
    hash.map { |key, value| "-#{letter} #{key}#{letter == 'd' ? '=' : ''}#{value}" }.join(' ')
  end

  def parse_json(str)
    Rails.logger.info(str)
    JSON.parse(str)
  end
end
