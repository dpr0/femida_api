class ThemisFraudScoreJob < ApplicationJob
  queue_as :themis_fraud_score

  def perform(user_id, phone, log_id:, try: 3, last_user: false)
    return if phone.blank?

    try -= 1
    phone_score = try.zero? ? score(phone, version: 1) : score(phone)
    if phone_score
      CsvUser.find(user_id).update(phone_score: phone_score)
    elsif try.positive?
      ThemisFraudScoreJob.perform_at(600, user_id, phone, log_id: log_id, try: try, last_user: last_user)
    end

    CsvParserLog.find(log_id).touch if last_user
  end

  private

  def score(phone, version: 2)
    resp = RestClient.get("#{ENV['THEMIS_FRAUD_API_HOST']}/models/fraud/v#{version}/7#{phone}")
    JSON.parse(resp.body)['score']
  rescue StandardError
    nil
  end
end
