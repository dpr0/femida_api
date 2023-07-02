# frozen_string_literal: true

# == Schema Information
#
# Table name: fssp_wanted
#
#  id         :bigint           not null, primary key
#  birthday   :string
#  first_name :string
#  last_name  :string
#  patronymic :string
#  region_id  :string
#
class FsspWanted < ApplicationRecord
  self.table_name = :fssp_wanted
end
