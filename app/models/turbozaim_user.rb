# frozen_string_literal: true

# == Schema Information
#
# Table name: turbozaim_users
#
#  id                     :bigint           not null, primary key
#  archive_fssp           :string
#  birth_date             :string
#  dateopen               :string
#  first_name             :string
#  has_double_citizenship :string
#  is_18                  :string
#  is_expired_passport    :string
#  is_in_black_list       :string
#  is_massive_supervisors :string
#  is_passport_verified   :string
#  is_passport_verified_2 :boolean
#  is_pdl                 :string
#  is_phone_verified      :string
#  is_phone_verified_2    :boolean
#  is_terrorist           :string
#  last_name              :string
#  middlename             :string
#  os_inns                :string
#  os_passports           :string
#  os_phones              :string
#  os_snils               :string
#  os_status              :string
#  passport               :string
#  phone                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  femida_id              :string
#  turbozaim_id           :string
#
class TurbozaimUser < ApplicationRecord
  has_many :turbozaim_user_datas
end
