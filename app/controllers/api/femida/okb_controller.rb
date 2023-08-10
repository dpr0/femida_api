# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  PATH = '/opt/cprocsp/bin/amd64/'
  HOST = 'https://idv-tst.bki-okb.com/'
  CLIENT_SECRET = 'c2087e61-2c6c-4ed9-ace8-8703ab9f5bda'

  api :GET, '/okb/:id', "Проверка ОКБ"
  def show
    with_error_handling do
      # #{PATH}certmgr -list -store umy
      # #{PATH}certmgr -list -store uroot
      curl = "
        #{PATH}curl -i -X POST -vvv \\
        --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY \\
        --cert 2fc4461b7e9705acc998203bf19df8296e252861:123 \\
      "
      auth = parse_json `#{curl} -H Content-Type:application/x-www-form-urlencoded \\
        -d client_id=ucb.client.6529_generic \\
        -d client_secret=#{CLIENT_SECRET} \\
        -d grant_type=client_credentials \\
        -d scope=openid \\
        #{HOST}auth
      `

      parse_json `#{curl} -H Content-Type:application/json \\
        -H "Authorization:Bearer #{auth['access_token']}" \\
        -H "X-Request-Id:#{CLIENT_SECRET}" \\
        -d '{
          "submission": {
            "identifier": "1",
            "date": "2022-12-18",
            "app_date": "2022-12-18"
          },
          "applicant": {
            "name": "ХАНТЕР",
            "surname": "ХАНТЕР",
            "patronymic": "ХАНТЕР",
            "birthday": "1988-01-09",
            "consent": "Y",
            "document": 1655054567,
            "issued_at": "2022-01-23",
            "telephone_number": "+79031234567"
          }
        }' \\
        #{HOST}verify
      `
    end
  end

  private

  def parse_json(str)
    Rails.logger.info(str)
    JSON.parse(str.split("\n\n").last)
  end
end
