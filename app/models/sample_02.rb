# frozen_string_literal: true

# == Schema Information
#
# Table name: sample_02
#
#  id          :bigint           not null, primary key
#  birth_date  :string
#  first_name  :string
#  last_name   :string
#  middle_name :string
#  passport    :string
#  phone       :string
#  resp        :text
#  customer_id :integer
#
# Indexes
#
#  index_sample_02_on_passport  (passport)
#  index_sample_02_on_phone     (phone)
#
class Sample02 < ApplicationRecord
  self.table_name = :sample_02
end
