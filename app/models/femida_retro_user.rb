# frozen_string_literal: true

# == Schema Information
#
# Table name: femida_retro_users
#
#  id                   :bigint           not null, primary key
#  birth_date           :string
#  first_name           :string
#  is_passport_verified :string
#  is_phone_verified    :string
#  last_name            :string
#  middle_name          :string
#  passport             :string
#  phone                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class FemidaRetroUser < ApplicationRecord
end
