# frozen_string_literal: true

class Api::Femida::FsspController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/fssp?', 'Проверка исполнительных производств'
  def index
    with_error_handling do
      headers = {
        'Accept' => '*/*',
        'Cookie' => 'connect.sid=s%3AopWUBKC1Yws0sGJgCpbZhlWiavC6iMRz.dNNttqXfD2B8HlyXcOXIOv%2Fxu8NjbCLjnh4bA%2ByWNdo',
        'Referer' => 'https://fssp.gov.ru/',
        'Connection' => 'keep-alive',
        'Sec-Fetch-Dest' => 'script',
        'Sec-Fetch-Mode' => 'no-cors',
        'Sec-Fetch-Site' => 'same-site'
      }
      str = "https://is-node6.fssp.gov.ru" + CGI.escape("/ajax_search?system=ip&is[extended]=1&nocache=1&is[variant]=1&is[region_id][0]=77&is[last_name]=#{params[:f]}&is[first_name]=#{params[:i]}&is[patronymic]=#{params[:o]}&is[date]=#{params[:birth_date]}&_=#{Time.now.to_i * 1000}")
      resp = JSON.parse RestClient.get(str, headers)
      # capcha = resp.body.split("<img src=\\\"").last.split("\\\"").first
      capcha = Nokogiri::HTML.parse(resp['data']).css('#capchaVisual').first.values.first
      resp2 = post_rucaptcha(capcha, phrase: 0, language: 1, lang: :ru)
      JSON.parse RestClient.get(str + "&code=#{CGI.escape(resp2.split('|').last)}", headers)
    end
  end
end
