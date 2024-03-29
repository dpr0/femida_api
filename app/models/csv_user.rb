# frozen_string_literal: true

# == Schema Information
#
# Table name: csv_users
#
#  id                          :bigint           not null, primary key
#  birth_date                  :string
#  first_name                  :string
#  info                        :text
#  is_card_verified            :boolean
#  is_card_verified_source     :string
#  is_passport_verified        :boolean
#  is_passport_verified_source :string
#  is_phone_verified           :boolean
#  is_phone_verified_source    :string
#  last_name                   :string
#  middle_name                 :string
#  passport                    :string
#  phone                       :string
#  phone_score                 :string
#  phone_score_source          :string
#  external_id                 :string
#  file_id                     :decimal(, )
#
# Indexes
#
#  index_csv_users_on_passport  (passport)
#  index_csv_users_on_phone     (phone)
#
class CsvUser < ApplicationRecord
  belongs_to :csv_parser, foreign_key: :file_id, primary_key: :file_id
end
