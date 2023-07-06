# frozen_string_literal: true

# == Schema Information
#
# Table name: oriflame_ru
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
#  index_oriflame_ru_on_phone  (phone)
#
class Leaks6 < ApplicationRecord
  self.table_name = :oriflame_ru
end
