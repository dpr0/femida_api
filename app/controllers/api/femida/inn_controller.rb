# frozen_string_literal: true

class Api::Femida::InnController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/inn', 'api/femida/inn?f=иванов&i=иван&o=иванович&date=31.12.1999&passport=1234567890'
  def index
    with_error_handling { InnService.call(params) }
  end


  api :GET, '/inn/:inn', 'Проверка ИНН)'
  def show
    with_error_handling { InnService.get_inn(params[:id]) }
  end
end
