class FemidaProdService
  include Singleton

  attr_reader :token

  def initialize
    @token = post_req('users/login', email: ENV['FEMIDA_PROD_API_LOGIN'], password: ENV['FEMIDA_PROD_API_PASSWORD'])['auth_token']
  end

  def okb_search(hash)
    post_req('femida/okb', okb: hash, 'Authorization' => "Bearer #{token}")
  end

  private

  def post_req(path, hash, headers = {})
    resp = RestClient.post("#{ENV['FEMIDA_PROD_API_HOST']}/api/#{path}", hash, headers)
    resp.code == 200 ? JSON.parse(resp.body) : { 'data' => [] }
  rescue
    { 'data' => [] }
  end
end
