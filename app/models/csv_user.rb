# frozen_string_literal: true

# == Schema Information
#
# Table name: csv_users
#
#  id                          :bigint           not null, primary key
#  birth_date                  :string
#  first_name                  :string
#  info                        :text
#  is_passport_verified        :boolean
#  is_passport_verified_source :string
#  is_phone_verified           :boolean
#  is_phone_verified_source    :string
#  last_name                   :string
#  middle_name                 :string
#  passport                    :string
#  phone                       :string
#  external_id                 :string
#  file_id                     :string
#
# Indexes
#
#  index_csv_users_on_passport  (passport)
#  index_csv_users_on_phone     (phone)
#
class CsvUser < ApplicationRecord
  belongs_to :csv_parser, foreign_key: :file_id, primary_key: :file_id

  def log(field, source)
    hash = {
      id: id,
      "is_#{field}_verified".to_sym => true,
      "is_#{field}_verified_source".to_sym => source
    }
    Rails.logger.info(hash)
    hash
  end
end
