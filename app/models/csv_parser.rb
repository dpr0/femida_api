# frozen_string_literal: true

# == Schema Information
#
# Table name: csv_parsers
#
#  id                         :bigint           not null, primary key
#  birth_date                 :integer
#  first_name                 :integer
#  headers                    :string
#  is_passport_verified_count :integer
#  is_phone_verified_count    :integer
#  last_name                  :integer
#  middle_name                :integer
#  passport                   :integer
#  phone                      :integer
#  rows                       :integer
#  saved                      :boolean
#  separator                  :string
#  external_id                :integer
#  file_id                    :integer
#
class CsvParser < ApplicationRecord
  has_many :csv_users
end
