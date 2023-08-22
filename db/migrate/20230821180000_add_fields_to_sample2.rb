# frozen_string_literal: true

class AddFieldsToSample2 < ActiveRecord::Migration[7.0]
  def change
    add_column :sample_02, :is_phone_verified, :boolean
    add_column :sample_02, :is_passport_verified, :boolean
  end
end
