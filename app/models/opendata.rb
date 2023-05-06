# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  filename   :string
#  number     :string
#  rows       :string
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Opendata < ApplicationRecord
  self.table_name = :opendata
end
