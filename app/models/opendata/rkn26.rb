# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn26
#
#  id          :bigint           not null, primary key
#  entryDate   :string
#  entryNum    :string
#  owner       :string
#  serviceName :string
#
class Opendata::Rkn26 < ApplicationRecord
  self.table_name = :opendata_rkn26
end
