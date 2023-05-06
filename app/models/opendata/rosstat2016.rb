# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_rosstat2016
#
#  id      :bigint           not null, primary key
#  inn     :string
#  measure :string
#  name    :string
#  okfs    :string
#  okopf   :string
#  okpo    :string
#  okved   :string
#  type    :string
#
class Opendata::Rosstat2016 < ApplicationRecord
  self.table_name = :opendata_rosstat2016
end
