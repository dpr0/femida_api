class CsvParserScoreJob < ApplicationJob
  queue_as :default

  def perform(hash)
    @parser = CsvParser.find_by(file_id: hash['id'])
    log = @parser.csv_parser_logs.new(info: self.class.name.underscore.sub('_job', ''))
    log.save(validate: false)
    @users = @parser.csv_users.where(phone_score: nil).order(id: :asc)
    @users.each do |user|
      ThemisFraudScoreJob.perform_async(user.id, user.phone, log.id, 3, @users.last.id == user.id)
    end
  end
end
