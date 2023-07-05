# frozen_string_literal: true

# == Schema Information
#
# Table name: moneyman_users
#
#  id          :bigint           not null, primary key
#  first_name  :string
#  last_name   :string
#  middle_name :string
#  passport    :string
#  phone       :string
#
class MoneymanUser < ApplicationRecord
end
