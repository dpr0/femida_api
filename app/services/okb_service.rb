class OkbService
  class << self
    def call(params, db = true)
      params[:consent] = 'Y'
      if params[:document].present?
        params[:document] = params[:document].to_i
        params[:issued_at] = params[:issued_at].to_date.to_s if params[:issued_at].present?
      else
        params.delete :document
        params.delete :issued_at
      end
      params[:birthday] = params[:birthday].to_date.to_s
      params[:telephone_number] = if params[:telephone_number].size == 10
        '+7' + params[:telephone_number]
      elsif params[:telephone_number].size == 11
        '+' + params[:telephone_number]
      else
        params[:telephone_number]
      end

      return if params[:telephone_number].blank?

      hash_req = {
        service:     :okb,
        phone:       params[:telephone_number].last(10),
        last_name:   params[:surname],
        first_name:  params[:name],
        middle_name: params[:patronymic],
        birth_date:  params[:birthday].to_date.strftime('%d.%m.%Y')
      }
      okb = Request.find_by(hash_req) if db

      return { 'score' => okb.response&.to_i || -5 } if okb

      curl = "/opt/cprocsp/bin/amd64/curl -i -X POST -vvv --cert #{ENV['CERT_SHA1_THUMBPRINT']}:#{ENV['CERT_PASSWORD']} --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY"
      hash = { client_id: ENV['OKB_CLIENT_ID'], client_secret: ENV['OKB_CLIENT_SECRET'], grant_type: 'client_credentials', scope: 'openid' }
      auth = parse_json :auth, "#{curl} -H Content-Type:application/x-www-form-urlencoded #{hash_to_str(hash, 'd')}"
      t = Time.now
      json = { applicant: params, submission: { identifier: t.to_i.to_s, date: t.to_date.to_s, app_date: t.to_date.to_s } }.to_json
      hash = { 'Content-Type:': 'application/json', 'Authorization:Bearer ': auth['access_token'], 'X-Request-Id:': Digest::UUID.uuid_v4 }
      resp = parse_json :verify, "#{curl} #{hash_to_str(hash, 'H')} -d '#{json}'"

      Request.create(hash_req.merge(response: resp['score']))
      resp
    end

    def hash_to_str(hash, letter)
      hash.map { |key, value| "-#{letter} \"#{key}#{'=' if letter == 'd'}#{value}\"" }.join(' ')
    end

    def parse_json(method, str)
      JSON.parse("{#{`#{str} #{ENV['OKB_HOST']}#{method}`.split('{')[1..].join}")
      # url = "#{ENV['OKB_HOST']}#{method}"
      # Rails.logger.info("=========== #{method.capitalize} REQUEST: ============ \n #{str} #{url}")
      # s = "{#{`#{str} #{url}`.split('{')[1..].join}"
      # Rails.logger.info("=========== #{method.capitalize} RESPONSE: =========== \n #{s}")
      # JSON.parse(s)
    rescue StandardError
      { 'score' => -5 }
    end
  end
end
