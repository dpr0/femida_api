# frozen_string_literal: true

# == Schema Information
#
# Table name: femida_retro_users
#
#  id                   :bigint           not null, primary key
#  birth_date           :string
#  first_name           :string
#  is_passport_verified :boolean
#  is_phone_verified    :boolean
#  last_name            :string
#  middle_name          :string
#  passport             :string
#  phone                :string
#
class FemidaRetroUser < ApplicationRecord
end
