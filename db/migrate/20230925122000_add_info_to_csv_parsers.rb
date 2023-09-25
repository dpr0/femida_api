# frozen_string_literal: true

class AddInfoToCsvParsers < ActiveRecord::Migration[7.0]
  def change
    add_column :csv_parsers, :info, :integer
    add_column :csv_parsers, :date_mask, :string
  end
end
