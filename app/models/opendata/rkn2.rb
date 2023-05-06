# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn2
#
#  id              :bigint           not null, primary key
#  addr_legal      :string
#  date_end        :string
#  date_start      :string
#  lic_status_name :string
#  licence_num     :string
#  name            :string
#  name_short      :string
#  ownership       :string
#  registration    :string
#  service_name    :string
#  territory       :string
#
class Opendata::Rkn2 < ApplicationRecord
  self.table_name = :opendata_rkn2
end
