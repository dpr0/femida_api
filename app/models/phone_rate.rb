# frozen_string_literal: true

# == Schema Information
#
# Table name: phone_rates
#
#  id         :bigint           not null, primary key
#  phone      :string
#  rate       :float
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PhoneRate < ApplicationRecord
end
