# frozen_string_literal: true

class AddCardToCsvParsers < ActiveRecord::Migration[7.0]
  def change
    add_column :csv_parsers, :is_card_verified_count, :integer
    add_column :csv_users, :is_card_verified, :boolean
    add_column :csv_users, :is_card_verified_source, :string
  end
end
