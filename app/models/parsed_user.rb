# frozen_string_literal: true

# == Schema Information
#
# Table name: parsed_users
#
#  id                :bigint           not null, primary key
#  address           :string
#  birth_date        :string
#  first_name        :string
#  is_phone_verified :string
#  last_name         :string
#  middle_name       :string
#  passport          :string
#  phone             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_parsed_users_on_phone  (phone)
#
class ParsedUser < ApplicationRecord
end
