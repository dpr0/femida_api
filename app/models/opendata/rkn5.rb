# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn5
#
#  id                :bigint           not null, primary key
#  cancellation_date :string
#  cancellation_num  :string
#  geo_zone          :string
#  license_num       :string
#  location          :string
#  order_date        :string
#  order_num         :string
#  org_name          :string
#  regno             :string
#  short_org_name    :string
#
class Opendata::Rkn5 < ApplicationRecord
  self.table_name = :opendata_rkn5
end
