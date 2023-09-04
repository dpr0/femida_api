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
#  separator                  :string
#  status                     :integer          default(0)
#  external_id                :integer
#  file_id                    :integer
#
class CsvParser < ApplicationRecord
  has_many :csv_users

  STATUSES = [
    'загружен',
    'распознаны заголовки',
    'начало инсерта в БД',
    'сохранено в БД',
    'запущена проверка',
    'проверка завершена',
    'запущена проверка окб',
    'проверка окб завершена'
  ].freeze
end
