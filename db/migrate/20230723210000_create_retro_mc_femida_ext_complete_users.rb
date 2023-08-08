# frozen_string_literal: true

class CreateRetroMcFemidaExtCompleteUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :retro_mc_femida_ext_complete_users do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :phone
      t.string :phone_old
      t.string :birth_date
      t.string :passport
      t.string :passport_old
      t.string :info
    end
  end
end
