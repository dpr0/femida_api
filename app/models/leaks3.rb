# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmate_all
#
#  daybirth    :integer
#  email       :text
#  information :json
#  middlename  :text
#  monthbirth  :integer
#  name        :text
#  surname     :text
#  yearbirth   :integer
#
class Leaks3 < ApplicationRecord
  self.table_name = :bookmate_all
end
