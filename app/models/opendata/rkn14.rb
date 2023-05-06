# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn14
#
#  id        :bigint           not null, primary key
#  measure   :string
#  name      :string
#  okei      :string
#  rowNumber :string
#  totalSum  :string
#
class Opendata::Rkn14 < ApplicationRecord
  self.table_name = :opendata_rkn14
end
