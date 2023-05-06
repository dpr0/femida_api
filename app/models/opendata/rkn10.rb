# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rkn10
#
#  id             :bigint           not null, primary key
#  AnnulledInfo   :string
#  Date           :string
#  DateFrom       :string
#  DateTo         :string
#  Num            :string
#  Owner          :string
#  Place          :string
#  RenewalInfo    :string
#  SuspensionInfo :string
#  Type           :string
#
class Opendata::Rkn10 < ApplicationRecord
  self.table_name = :opendata_rkn10
end
