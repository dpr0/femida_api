# frozen_string_literal: true

# == Schema Information
#
# Table name: xfit_users
#
#  daybirth    :integer
#  email       :text
#  information :json
#  middlename  :text
#  monthbirth  :integer
#  name        :text
#  phone       :text
#  surname     :text
#  yearbirth   :integer
#
# Indexes
#
#  index_xfit_users_on_phone  (phone)
#
class Leaks8 < ApplicationRecord
  self.table_name = :xfit_users
end
