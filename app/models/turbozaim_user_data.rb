# frozen_string_literal: true

# == Schema Information
#
# Table name: turbozaim_user_data
#
#  id                   :bigint           not null, primary key
#  actual_date          :string
#  address              :string
#  birthdate            :string
#  birthplace           :string
#  citizenship          :string
#  credit_sum           :string
#  credit_type          :string
#  date                 :string
#  date_from            :string
#  delo_article         :string
#  delo_date            :string
#  delo_date2           :string
#  delo_initiator       :string
#  delo_num             :string
#  email                :string
#  fact_address         :string
#  fact_region          :string
#  field0               :string
#  field1               :string
#  field2               :string
#  field3               :string
#  field4               :string
#  field5               :string
#  field6               :string
#  field7               :string
#  field8               :string
#  field9               :string
#  ifns                 :string
#  info                 :string
#  inn                  :string
#  insurance            :string
#  kbm                  :string
#  limitation           :string
#  model                :string
#  name                 :string
#  nationality          :string
#  ogrn                 :string
#  old_address          :string
#  old_birthdate        :string
#  old_first_name       :string
#  old_last_name        :string
#  old_middle_name      :string
#  organization         :string
#  organization_inn     :string
#  overdue_days         :string
#  passport             :string
#  passport_date        :string
#  passport_organ       :string
#  phone                :string
#  phone2               :string
#  phone3               :string
#  polis                :string
#  premium_sum          :string
#  registration_address :string
#  registration_region  :string
#  snils                :string
#  source               :string
#  sum                  :string
#  target               :string
#  vin                  :string
#  workplace            :string
#  workplace_address    :string
#  workplace_phone      :string
#  workplace_position   :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  turbozaim_user_id    :string
#
class TurbozaimUserData < ApplicationRecord
  belongs_to :turbozaim_user
end
