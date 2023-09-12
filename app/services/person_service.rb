class PersonService
  include Singleton

  attr_reader :token

  def initialize
    @token = post_req(
      {
        email: ENV['FEMIDA_PERSONS_API_LOGIN'],
        password: ENV['FEMIDA_PERSONS_API_PASSWORD']
      },
      'users/login'
    )['auth_token']
  end

  def search(hash)
    post_req(hash, 'persons/search', 'Authorization' => "Bearer #{token}")
  end

  private

  def post_req(hash, path, headers = {})
    resp = RestClient.post("#{ENV['FEMIDA_PERSONS_API_HOST']}/api/#{path}", hash, headers)
    resp.code == 200 ? JSON.parse(resp.body) : {}
  rescue
    {}
  end
end
