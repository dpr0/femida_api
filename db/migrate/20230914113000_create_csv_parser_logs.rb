# frozen_string_literal: true

class CreateCsvParserLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_parser_logs do |t|
      t.integer :csv_parser_id
      t.integer :is_phone_verified_count
      t.integer :is_passport_verified_count
      t.string :info

      t.timestamps null: false
    end

    add_column :csv_users, :phone_score, :string
    add_column :csv_users, :phone_score_source, :string
    # change_column :csv_users, :file_id, 'numeric USING CAST(file_id AS numeric)'
  end
end
