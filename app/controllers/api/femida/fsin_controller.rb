# frozen_string_literal: true

class Api::Femida::FsinController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/fsin/:fio', 'Проверка ФСИН (РОЗЫСК) - json array: [{"fio": "", "dt": ""}] (https://limited.fsin.gov.ru/criminal/)'
  def show
    with_error_handling { FsinService.new(params[:id]).call }
  end
end
