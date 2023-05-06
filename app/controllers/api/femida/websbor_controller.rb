# frozen_string_literal: true

class Api::Femida::WebsborController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/websbor?inn=1&okpo=2&ogrn=3', 'Проверка  (https://websbor.gks.ru)'
  def index
    with_error_handling do
      inn = check_inn(params[:inn])

      JSON.parse RestClient.post(
        'https://websbor.gks.ru/webstat/api/gs/organizations',
        okpo: params[:okpo], inn: inn, ogrn: params[:ogrn]
      )
    end
  end
end
