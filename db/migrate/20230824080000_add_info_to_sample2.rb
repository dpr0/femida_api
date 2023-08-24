# frozen_string_literal: true

class AddInfoToSample2 < ActiveRecord::Migration[7.0]
  def change
    add_column :sample_02, :info, :string
  end
end
