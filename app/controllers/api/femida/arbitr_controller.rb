# frozen_string_literal: true

class Api::Femida::ArbitrController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/arbitr/:inn', 'Поиск решений арбитражного суда - json: { link: , num: , judge: , title: , name: , dt: } (https://kad.arbitr.ru/Kad/SearchInstances)'
  def show
    with_error_handling do
      wasm = params[:wasm] || '94d8feaa44c2fa8467c6106a95ed52e2' # '68D5834C6D9AE0EBB645C93DA0272857'
      pr_fp = params[:pr_fp] || '5b903731b740ab0bd41d36af1140b29d2d72808ef204f6bc70e98c873086dba0'
      inn = check_inn(params[:id])
      ArbitrService.new(inn, wasm, pr_fp).call
    end
  end
end
