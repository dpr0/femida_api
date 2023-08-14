class OkbService
  def self.call(params)
    curl = "/opt/cprocsp/bin/amd64/curl -i -X POST -vvv --cert #{ENV['CERT_SHA1_THUMBPRINT']}:#{ENV['CERT_PASSWORD']} --cert-type CERT_SHA1_HASH_PROP_ID:CERT_SYSTEM_STORE_CURRENT_USER:MY"
    hash = { client_id: ENV['OKB_CLIENT_ID'], client_secret: ENV['OKB_CLIENT_SECRET'], grant_type: 'client_credentials', scope: 'openid' }
    auth = parse_json :auth, "#{curl} -H Content-Type:application/x-www-form-urlencoded #{hash_to_str(hash, 'd')}"
    t = Time.now
    json = { applicant: params, submission: { identifier: t.to_i.to_s, date: t.to_date.to_s, app_date: t.to_date.to_s } }.to_json
    hash = { 'Content-Type:': 'application/json', 'Authorization:Bearer ': auth['access_token'], 'X-Request-Id:': ENV['OKB_CLIENT_SECRET'] }
    parse_json :verify, "#{curl} #{hash_to_str(hash, 'H')} -d '#{json}'"
  end

  private

  def self.hash_to_str(hash, letter)
    hash.map { |key, value| "-#{letter} \"#{key}#{'=' if letter == 'd'}#{value}\"" }.join(' ')
  end

  def self.parse_json(method, str)
    JSON.parse("{#{`#{str} #{ENV['OKB_HOST']}#{method}`.split('{')[1..].join}")
  end
end
