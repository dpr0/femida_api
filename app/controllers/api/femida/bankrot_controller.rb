# frozen_string_literal: true

class Api::Femida::BankrotController < ApplicationController
  protect_from_forgery with: :null_session

  BHOST = 'https://bankrot.fedresurs.ru'
  HOST = 'https://fedresurs.ru'

  api :GET, '/bankrot/:inn', ''
  def show
    with_error_handling do
      @inn = check_inn(params[:id])
      data = get('cmpbankrupts')['pageData'] + get('prsnbankrupts')['pageData']
      infos = data.map { |x| get_info_by(x['guid']) }
      publications = data.map { |x| get_by(x['guid'])['pageData'] }
      { data: data, infos: infos, publications: publications }
    end
  end

  private

  def get(type)
    JSON.parse RestClient.get(
      "#{BHOST}/backend/#{type}?searchString=#{@inn}&isActiveLegalCase=null&limit=15&offset=0",
      'Referer' => BHOST
    )
  end

  def get_info_by(guid)
    JSON.parse RestClient.get("#{HOST}/backend/companies/#{guid}", headers)
  end

  def get_by(guid)
    JSON.parse RestClient.get(
      "#{HOST}/backend/companies/#{guid}/publications?limit=15&offset=0&searchCompanyEfrsb=true&searchAmReport=true&searchFirmBankruptMessage=true&searchFirmBankruptMessageWithoutLegalCase=false&searchSfactsMessage=true&searchSroAmMessage=true&searchTradeOrgMessage=true",
      headers
    )
  end

  def headers
    {
      'Accept' => 'application/json, text/plain, */*',
      'Cookie' => 'fedresurscookie=88a8462de85ce5b7bfe4a7ee5a12d525;',
      'Referer' => HOST,
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
    }
  end
end
