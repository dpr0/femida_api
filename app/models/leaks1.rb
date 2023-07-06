# frozen_string_literal: true

# == Schema Information
#
# Table name: lukoil_txt
#
#  middlename :text
#  name       :text
#  phone      :text
#  surname    :text
#
# Indexes
#
#  index_lukoil_txt_on_phone  (phone)
#
class Leaks1 < ApplicationRecord
  self.table_name = :lukoil_txt
end
