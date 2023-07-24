# frozen_string_literal: true

# == Schema Information
#
# Table name: retro_mc_femida_ext_users
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
class RetroMcFemidaExtUser < ApplicationRecord
  has_many :retro_mc_femida_ext_complete_users, foreign_key: :phone_old, primary_key: :phone
end
