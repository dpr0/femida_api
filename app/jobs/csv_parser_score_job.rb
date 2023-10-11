class CsvParserScoreJob < ApplicationJob
  queue_as :default

  def perform(hash)
    ScoreService.new(hash['id']).upload
  end
end
