# frozen_string_literal: true

# == Schema Information
#
# Table name: sro_members
#
#  id         :bigint           not null, primary key
#  full_name  :string
#  inn        :string
#  ogrn       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sro_id     :integer
#
class SroMember < ApplicationRecord
  belongs_to :sro
  has_many :sro_kinds
end
