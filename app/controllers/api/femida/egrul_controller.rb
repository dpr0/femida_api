# frozen_string_literal: true

class Api::Femida::EgrulController < ApplicationController
  protect_from_forgery with: :null_session
  URL = 'https://egrul.nalog.ru/'.freeze

  api :GET, '/egrul/:inn', "Проверка ЕГРЮЛ (#{URL}index.html)"
  def show
    with_error_handling do
      @inn = check_inn(params[:id])
      @errors = []
      token = begin
                post_request
              rescue Errno::ECONNRESET => e
                post_request
              end

      data = JSON.parse(token)
      resp = begin
               get_req('search-result', data['t'])
             rescue Errno::ECONNRESET => e
               get_req('search-result', data['t'])
             end

      JSON.parse(resp)['rows'].map { |row| transform(row) }
    end
  end

  private

  def transform(row)
    get_req('vyp-request', row['t'])
    {
      start_at: row['r'],
      end_at: row['e'],
      pdf: "#{URL}vyp-download/#{row['t']}",
      pg: row['pg'],
      tot: row['tot'],
      cnt: row['cnt'],
      address: row['a'],
      short_name: row['c'],
      full_name: row['n'],
      gendir: row['g'],
      form: row['k'],
      kpp: row['p'],
      ogrn: row['o']
    }
  end

  def get_req(path, token)
    RestClient.get("#{URL}#{path}/#{token}")
  end

  def post_request
    RestClient.post(URL, "vyp3CaptchaToken=&page=&query=#{@inn}&region=&PreventChromeAutocomplete=")
  end
end
