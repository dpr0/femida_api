# frozen_string_literal: true

# == Schema Information
#
# Table name: skyeng_full_csv
#
#  daybirth    :integer
#  email       :text
#  information :json
#  monthbirth  :integer
#  name        :text
#  phone       :text
#  surname     :text
#  yearbirth   :integer
#
# Indexes
#
#  index_skyeng_full_csv_on_phone  (phone)
#
class Leaks4 < ApplicationRecord
  self.table_name = :skyeng_full_csv
end
