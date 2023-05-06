# frozen_string_literal: true

class Api::Femida::BonalogController < ApplicationController
  protect_from_forgery with: :null_session
  URL = 'https://bo.nalog.ru/nbo'

  api :GET, '/bonalog?query=string', 'Проверка бух/фин отчетности- (https://bo.nalog.ru/)'
  def index
    with_error_handling do
      response = get("organizations/search?query=#{CGI.escape params[:query]}")['content'].first
      response[:info] = get("organizations/#{response['id']}/bfo").map do |resp|
        {
          correctionList:       get("cb/getCbCorrectionList?organizationId=#{response['id']}&period=#{resp['period']}"),
          organizations:        get("bfo/#{resp['id']}/organizations"),
          details:              get("bfo/#{resp['id']}/details").map do |detail|
            {
              balance:          get("details/balance?id=#{detail['id']}"),
              financial_result: get("details/financial_result?id=#{detail['id']}"),
              capital_change:   get("details/capital_change?id=#{detail['id']}"),
              funds_movement:   get("details/funds_movement/v2?id=#{detail['id']}")
            }
          end
        }
      end
      response
    end
  end

  private

  def get(url)
    JSON.parse RestClient.get("#{URL}/#{url}")
  end
end
