# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn13
#
#  id               :bigint           not null, primary key
#  address          :string
#  address_activity :string
#  control_form     :string
#  date_last        :string
#  date_reg         :string
#  date_start       :string
#  goal             :string
#  inn              :string
#  ogrn             :string
#  org_name         :string
#  orgs             :string
#  plan_year        :string
#  work_day_cnt     :string
#
class Opendata::Rkn13 < ApplicationRecord
  self.table_name = :opendata_rkn13
end
