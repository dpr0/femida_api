class ParserWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(hash)
    byebug
  end
end
