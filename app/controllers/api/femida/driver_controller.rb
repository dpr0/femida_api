# frozen_string_literal: true

class Api::Femida::DriverController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/driver?', 'Проверка водителя'
  def index
    with_error_handling do
      capcha = JSON.parse RestClient.get('https://check.gibdd.ru/captcha')
      resp = post_rucaptcha(capcha['base64jpg'])
      string = "num=#{params[:num]}&date=#{params[:date]}&captchaWord=#{resp.body.split('|').last}&captchaToken=#{capcha['token']}"
      JSON.parse RestClient.post('https://xn--b1afk4ade.xn--90adear.xn--p1ai/proxy/check/driver', string)
    end
  end

  def kbm
    rucaptcha = RestClient.post("#{URL}/in.php", key: ENV['RUCAPTCHA_KEY'], googlekey: '6Ld33nEUAAAAAOwr4DVWNT5k0dnCBZCI8INqXIJ_', method: 'userrecaptcha', pageurl: 'https://kbm-rsa.info/').body
  end
end


# 6Ld33nEUAAAAAOwr4DVWNT5k0dnCBZCI8INqXIJ_

# curl 'https://kbm-rsa.info/' \
#   -H 'authority: kbm-rsa.info' \
#   -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
#   -H 'accept-language: ru,en;q=0.9,fr;q=0.8,uk;q=0.7,bg;q=0.6,pt;q=0.5' \
#   -H 'cache-control: max-age=0' \
#   -H 'content-type: application/x-www-form-urlencoded' \
#   -H 'cookie: _ga=GA1.2.845746706.1676020991; _gid=GA1.2.2100990329.1676020991; _ym_uid=1676020991348916212; _ym_d=1676020991' \
#   -H 'origin: https://kbm-rsa.info' \
#   -H 'referer: https://kbm-rsa.info/' \
#   -H 'sec-ch-ua: "Not_A Brand";v="99", "Google Chrome";v="109", "Chromium";v="109"' \
#   -H 'sec-ch-ua-mobile: ?0' \
#   -H 'sec-ch-ua-platform: "macOS"' \
#   -H 'sec-fetch-dest: document' \
#   -H 'sec-fetch-mode: navigate' \
#   -H 'sec-fetch-site: same-origin' \
#   -H 'sec-fetch-user: ?1' \
#   -H 'upgrade-insecure-requests: 1' \
#   -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36' \
#   --data-raw 'lastname=%D0%90%D0%B1%D1%83%D0%BB%D0%BE%D0%B2&firstname=%D0%A5%D0%B0%D0%BA%D0%B0%D0%BD&middlename=%D0%93%D0%B0%D0%B4%D0%B6%D0%B8%D0%B0%D1%85%D0%BC%D0%B5%D0%B4+%D0%BE%D0%B3%D0%BB%D1%8B&birthday=05.04.1999&driverlicense_s=9902&driverlicense_n=355888&action='

