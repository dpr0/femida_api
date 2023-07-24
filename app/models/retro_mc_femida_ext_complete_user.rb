# frozen_string_literal: true

# == Schema Information
#
# Table name: retro_mc_femida_ext_complete_users
#
#  id           :bigint           not null, primary key
#  birth_date   :string
#  first_name   :string
#  info         :string
#  last_name    :string
#  middle_name  :string
#  passport     :string
#  passport_old :string
#  phone        :string
#  phone_old    :string
#
class RetroMcFemidaExtCompleteUser < ApplicationRecord
  belongs_to :retro_mc_femida_ext_user, foreign_key: :phone, primary_key: :phone_old
end
