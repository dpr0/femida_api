class ExpiredPassportsJob < ApplicationJob
  queue_as :default

  def perform()
    File.readlines(Rails.root.join('tmp', 'narod', 'expired_passports.csv')).each do |line|
      series, number = line.chomp.split(',')
      pasp = ExpiredPassport.find_or_initialize_by(passp_series: series, passp_number: number)
      pasp.save unless pasp.id
    end
  end
end
