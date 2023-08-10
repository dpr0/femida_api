# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/okb/:id', "Проверка ОКБ"
  def show
    with_error_handling do
      str = '
        /opt/cprocsp/bin/amd64/curl -i -X POST -vvv \
        --cert-type "CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY" \
        --cert "2fc4461b7e9705acc998203bf19df8296e252861" \
        -H "Content-Type:application/x-www-form-urlencoded" \
        -d "client_id=ucb.client.6529_generic" \
        -d "client_secret=c2087e61-2c6c-4ed9-ace8-8703ab9f5bda" \
        -d "grant_type=client_credentials" \
        -d "scope=openid" \
        https://idv-tst.bki-okb.com/auth
      '
      resp = system str
      Logger.info("======================================================================")
      Logger.info(resp)
      data = JSON.parse(resp)
      Logger.info(data)
      data
    end
  end

  private
end
