# frozen_string_literal: true

class CreateTurbozaimUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :turbozaim_users do |t|
      t.string :turbozaim_id
      t.string :dateopen
      t.string :last_name
      t.string :first_name
      t.string :middlename
      t.string :birth_date
      t.string :passport
      t.string :phone
      t.string :femida_id
      t.string :os_status
      t.string :is_expired_passport
      t.string :is_massive_supervisors
      t.string :is_terrorist
      t.string :is_phone_verified
      t.string :is_18
      t.string :is_in_black_list
      t.string :has_double_citizenship
      t.string :is_pdl
      t.string :os_inns
      t.string :os_phones
      t.string :os_passports
      t.string :os_snils
      t.string :archive_fssp
      t.string :is_passport_verified

      t.timestamps null: false
    end
  end
end
