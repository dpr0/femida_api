# frozen_string_literal: true

class ApplicationController < ActionController::Base
  RETRY = 30
  URL = 'http://rucaptcha.com'
  ERROR = 'ERROR_CAPTCHA_UNSOLVABLE'
  private

  def post_rucaptcha(body, attrs = {})
    params = { key: ENV['RUCAPTCHA_KEY'], body: body, method: 'base64' }
    rucaptcha = RestClient.post("#{URL}/in.php", params.merge(attrs))
    id = rucaptcha.body.split('|').last
    x = 0
    resp = get_rucaptcha(id)
    while x < RETRY
      x += 1
      resp = get_rucaptcha(id)
      puts "#{x}: #{resp.body}"
      x = RETRY if resp.body == ERROR
      resp.body[0..1] == 'OK' ? (x = RETRY) : sleep(1.second)
    end
    resp.body
  end

  def get_rucaptcha(id)
    RestClient.get("#{URL}/res.php?key=#{ENV['RUCAPTCHA_KEY']}&action=get&id=#{id}")
  end

  def with_error_handling
    error = nil
    body = begin
             yield
           rescue Exception => e
             error = e.message
           end
    render status: :ok, json: error.present? ? { status: false, error: error } : body
  end

  def check_inn(inn)
    array = [7, 2, 4, 10, 3, 5, 9, 4, 6, 8]
    if inn.scan(/\D/).present?
      raise 'inn must contains only digits'
    elsif inn.size == 10
      array.shift
      check(inn, array) == inn[-1].to_i ? inn : raise('inn not valid')
    elsif inn.size == 12
      check(inn, array) == inn[-2].to_i && check(inn, [3] + array) == inn[-1].to_i ? inn : raise('inn not valid')
    else
      raise 'inn size must be 10 or 12 digits'
    end
  end

  def check(inn, array)
    sum = 0
    inn[0..array.size-1].each_char.with_index { |x, i| sum += array[i] * x.to_i }
    sum % 11 % 10
  end
end
