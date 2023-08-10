# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  PATH = '/opt/cprocsp/bin/amd64/'

  api :GET, '/okb/:id', "Проверка ОКБ"
  def show
    with_error_handling do
      # #{PATH}certmgr -list -store umy
      # #{PATH}certmgr -list -store uroot
      str = `
        #{PATH}curl -i -X POST -vvv \\
        --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY \\
        --cert 2fc4461b7e9705acc998203bf19df8296e252861:123 \\
        -H Content-Type:application/x-www-form-urlencoded \\
        -d client_id=ucb.client.6529_generic \\
        -d client_secret=c2087e61-2c6c-4ed9-ace8-8703ab9f5bda \\
        -d grant_type=client_credentials \\
        -d scope=openid \\
        https://idv-tst.bki-okb.com/auth
      `
      Rails.logger.info(str)
      JSON.parse(str)
    end
  end

  private
end
