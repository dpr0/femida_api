# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :authenticate_request TODO разкоментить после добавления jwt в themis_server

  api :POST, '/okb', 'Проверка ОКБ'
  def create
    with_error_handling { OkbService.call(params[:okb]) }
  end

  api :POST, '/okb_req', 'Проверка ОКБ в бд'
  def okb_req
    with_error_handling { OkbService.check_in_db(params) }
  end
end
