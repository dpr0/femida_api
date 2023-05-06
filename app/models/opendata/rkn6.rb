# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn6
#
#  id               :bigint           not null, primary key
#  address          :string
#  basis            :string
#  db_country       :string
#  encryption       :string
#  enter_date       :string
#  enter_order      :string
#  enter_order_date :string
#  enter_order_num  :string
#  income_date      :string
#  inn              :string
#  is_list          :string
#  name_full        :string
#  pd_operator_num  :string
#  purpose_txt      :string
#  resp_name        :string
#  rf_subjects      :string
#  startdate        :string
#  status           :string
#  stop_condition   :string
#  territory        :string
#  transgran        :string
#
class Opendata::Rkn6 < ApplicationRecord
  self.table_name = :opendata_rkn6
end
