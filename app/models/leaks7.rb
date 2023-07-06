# frozen_string_literal: true

# == Schema Information
#
# Table name: kinokassa_ru_orders
#
#  email       :text
#  information :json
#  phone       :text
#
# Indexes
#
#  index_kinokassa_ru_orders_on_phone  (phone)
#
class Leaks7 < ApplicationRecord
  self.table_name = :kinokassa_ru_orders
end
