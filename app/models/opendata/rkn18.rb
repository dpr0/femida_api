# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn18
#
#  id                :bigint           not null, primary key
#  accreditationDate :string
#  degree            :string
#  education         :string
#  email             :string
#  expertiseSubject  :string
#  name              :string
#  orderNum          :string
#  status            :string
#  validity          :string
#
class Opendata::Rkn18 < ApplicationRecord
  self.table_name = :opendata_rkn18
end
