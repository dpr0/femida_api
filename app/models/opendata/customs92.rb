# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_customs92
#
#  id                        :bigint           not null, primary key
#  start_date                :string
#  vehicle_body_number       :string
#  vehicle_chassis_number    :string
#  vehicle_from_country      :string
#  vehicle_from_country_naim :string
#  vehicle_vin               :string
#
class Opendata::Customs92 < ApplicationRecord
  self.table_name = :opendata_customs92
end
