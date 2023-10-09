# frozen_string_literal: true

# == Schema Information
#
# Table name: csv_parser_logs
#
#  id                         :bigint           not null, primary key
#  info                       :string
#  is_card_verified_count     :integer
#  is_passport_verified_count :integer
#  is_phone_verified_count    :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  csv_parser_id              :integer
#
class CsvParserLog < ApplicationRecord
  belongs_to :csv_parser
end
