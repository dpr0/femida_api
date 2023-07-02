# frozen_string_literal: true

# == Schema Information
#
# Table name: expired_passports
#
#  id           :bigint           not null, primary key
#  passp_number :string
#  passp_series :string
#
# Indexes
#
#  expired_passports_passp_series_index  (passp_series)
#
class ExpiredPassport < ApplicationRecord

end
