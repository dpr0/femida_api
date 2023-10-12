# frozen_string_literal: true

# == Schema Information
#
# Table name: csv_parsers
#
#  id                         :bigint           not null, primary key
#  birth_date                 :integer
#  date_mask                  :string
#  first_name                 :integer
#  headers                    :string
#  info                       :integer
#  is_card_verified_count     :integer
#  is_passport_verified_count :integer
#  is_phone_verified_count    :integer
#  last_name                  :integer
#  middle_name                :integer
#  passport                   :integer
#  phone                      :integer
#  rows                       :integer
#  separator                  :string
#  status                     :integer          default(0)
#  external_id                :integer
#  file_id                    :integer
#
class CsvParser < ApplicationRecord
  has_many :csv_users,          foreign_key: :file_id,       primary_key: :file_id
  has_many :csv_parser_logs,    foreign_key: :csv_parser_id, primary_key: :file_id

  STATUSES = [
    'Загружен',
    'Распознан',
    'Сохранение',
    'Готов к обогащению',
    'Идет обогащение',
    'Файл готов'
  ].freeze
end
