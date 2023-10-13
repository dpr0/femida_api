class ThemisFraudScoreJob < ApplicationJob
  queue_as :themis_fraud_score

  def perform(user_id, phone, log_id, try = 3, last_user = false)
    return if phone.blank?

    try -= 1
    phone_score = try.zero? ? score(phone, version: 1) : score(phone)
    if phone_score
      CsvUser.find(user_id).update(phone_score: phone_score)
    elsif try.positive?
      ThemisFraudScoreJob.perform_at(600, user_id, phone, log_id, try, last_user)
    end

    if last_user
      user = CsvUser.find(user_id)
      count = CsvUser.where(file_id: user.file_id).where.not(phone_score: nil).count
      CsvParserLog.find(log_id).update(is_phone_verified_count: count)
    end
  end

  private

  def score(phone, version: 2)
    path = "/models/fraud/v#{version}/7#{phone}"
    resp = RestClient.get(ENV['THEMIS_FRAUD_API_HOST'] + path)
    Rails.logger.info("============== #{path} #{resp.body}")
    JSON.parse(resp.body)['score']
  rescue StandardError => e
    Rails.logger.error("============== phone #{phone} score error: #{e}")
    nil
  end
end
