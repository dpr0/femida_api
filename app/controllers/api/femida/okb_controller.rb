# frozen_string_literal: true

class Api::Femida::OkbController < ApplicationController
  protect_from_forgery with: :null_session

  api :POST, '/okb', 'Проверка ОКБ'
  def create
    with_error_handling { OkbService.call(params[:okb]) }
  end
end
