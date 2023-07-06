# frozen_string_literal: true

# == Schema Information
#
# Table name: sogaz
#
#  birth_day   :text
#  birth_month :text
#  birth_year  :text
#  email       :text
#  first_name  :text
#  information :text
#  last_name   :text
#  phone       :text
#  second_name :text
#
# Indexes
#
#  index_sogaz_on_phone  (phone)
#
class Leaks2 < ApplicationRecord
  self.table_name = :sogaz
end
