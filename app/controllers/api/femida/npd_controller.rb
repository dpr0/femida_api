# frozen_string_literal: true

class Api::Femida::NpdController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/npd/:inn', 'Проверка самозанятого - json: {"status": boolean, "message": string} (https://npd.nalog.ru/check-status/)'
  def show
    with_error_handling do
      inn = check_inn(params[:id])

      x = 0
      while x < RETRY
        @error = nil
        x += 1
        resp = post_request(inn)
        puts x
        resp.try(:code) == 200 ? (x = RETRY) : sleep(1)
      end

      JSON.parse(resp.body)
    end
  end

  private

  def post_request(inn)
    z = { inn: inn, requestDate: params[:date] || Date.current.to_s }.to_json
    RestClient.post('https://statusnpd.nalog.ru/api/v1/tracker/taxpayer_status', z, content_type: 'application/json')
  rescue RestClient::UnprocessableEntity => e
    @error = e.message
  end
end
