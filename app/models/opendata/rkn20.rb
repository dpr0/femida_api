# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn20
#
#  id                      :bigint           not null, primary key
#  distributorEmail        :string
#  distributorINN          :string
#  distributorLegalAddress :string
#  distributorName         :string
#  distributorOGRN         :string
#  distributorPersons      :string
#  entryDate               :string
#  entryNum                :string
#  services                :string
#
class Opendata::Rkn20 < ApplicationRecord
  self.table_name = :opendata_rkn20
end
