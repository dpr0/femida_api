# frozen_string_literal: true

class Api::Femida::DebtorsController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/debtors/:inn', 'Поиск задолженностей - csv (https://fssp.gov.ru/vnimanie_rozysk/action/debtors/)'
  def show
    inn = check_inn(params[:id])
    send_data(DebtorsService.new(inn).call, filename: 'response.csv', type: 'text/csv')
  rescue Exception => e
    render status: :ok, json: { status: false, error: e.message }
  end
end
