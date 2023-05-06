# frozen_string_literal: true

# == Schema Information
#
# Table name: sro
#
#  id         :bigint           not null, primary key
#  address    :string
#  email      :string
#  full_name  :string
#  inn        :string
#  number     :integer
#  ogrn       :string
#  phone      :string
#  website    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Sro < ApplicationRecord
  self.table_name = :sro

  has_many :sro_members
  has_many :sro_kinds
end
