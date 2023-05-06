# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn3
#
#  id               :bigint           not null, primary key
#  annulled_date    :string
#  domain_name      :string
#  form_spread      :string
#  founders         :string
#  langs            :string
#  name             :string
#  reg_date         :string
#  reg_number       :string
#  rus_name         :string
#  staff_address    :string
#  status_comment   :string
#  suspension_date  :string
#  termination_date :string
#  territory        :string
#  territory_ids    :string
#  form_spread_id   :string
#  reg_number_id    :string
#  status_id        :string
#
class Opendata::Rkn3 < ApplicationRecord
  self.table_name = :opendata_rkn3
end
