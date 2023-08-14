# frozen_string_literal: true

# == Schema Information
#
# Table name: expired_passports
#
#  id           :bigint           not null, primary key
#  passp_number :string
#  passp_series :string
#
class ExpiredPassport < ApplicationRecord

end
