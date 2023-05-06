# frozen_string_literal: true

# == Schema Information
#
# Table name: sro_kinds
#
#  id            :bigint           not null, primary key
#  end_date      :date
#  kind          :string
#  start_date    :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sro_id        :integer
#  sro_member_id :integer
#
class SroKind < ApplicationRecord
  belongs_to :sro
  belongs_to :sro_member
end
