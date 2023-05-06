# frozen_string_literal: true

class Api::Femida::InnController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/inn', 'api/femida/inn?f=иванов&i=иван&o=иванович&date=31.12.1999&passport=1234567890'
  def index
    with_error_handling do
      passport = params[:passport]
      payload = {
        c: 'find',
        fam: params[:f],
        nam: params[:i],
        otch: params[:o],
        bdate: params[:date],
        docno: "#{passport[0..1]} #{passport[2..3]} #{passport[4..9]}",
        doctype: '21'
      }

      url = 'https://service.nalog.ru/inn-new-proc.json'
      json = req(url, payload)
      json = req(url, { c: 'get', requestId: json['requestId'] })
      json.delete 'result'
      json
    end
  end


  api :GET, '/inn/:inn', 'Проверка ФЛ на долги - json: {"error": 0, "finesList": [], "count": null, "inGarage": 0} (https://gosnalogi.ru/ajax/taxes_inn)'
  def show
    with_error_handling do
      inn = check_inn(params[:id])
      json = req("https://gosnalogi.ru/ajax/taxes_inn?inn=#{inn}", {}, method: :get)
      json['error'] = json['error'].to_i
      json
    end
  end

  private

  def req(url, payload, method: :post)
    JSON.parse RestClient::Request.execute(url: url, payload: payload, method: method, verify_ssl: false)
  end
end
