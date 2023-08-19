class InnService
  class << self
    def call(params)
      passport = params[:passport]
      payload = {
        c: 'find',
        fam: params[:f],
        nam: params[:i],
        otch: params[:o],
        bdate: params[:date],
        docno: "#{passport[0..1]} #{passport[2..3]} #{passport[4..9]}",
        doctype: '21'
      }

      url = 'https://service.nalog.ru/inn-new-proc.json'
      json = req(url, payload)
      json = req(url, { c: 'get', requestId: json['requestId'] })
      json.delete 'result'
      json
    end

    def get_inn(inn)
      json = req("https://gosnalogi.ru/ajax/taxes_inn?inn=#{check_inn(inn.to_s)}", {}, method: :get)
      json['error'] = json['error'].to_i
      json
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

    private

    def check(inn, array)
      sum = 0
      inn[0..array.size-1].each_char.with_index { |x, i| sum += array[i] * x.to_i }
      sum % 11 % 10
    end

    def req(url, payload, method: :post)
      JSON.parse RestClient::Request.execute(url: url, payload: payload, method: method, verify_ssl: false)
    end
  end
end
