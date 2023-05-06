# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_fssp6
#
#  id                       :bigint           not null, primary key
#  actual_address           :string
#  address                  :string
#  amount_due               :string
#  date_proceeding          :string
#  debt                     :string
#  debtor_tin               :string
#  departments              :string
#  departments_address      :string
#  doc_date                 :string
#  doc_number               :string
#  doc_type                 :string
#  docs_object              :string
#  execution_object         :string
#  name                     :string
#  number_proceeding        :string
#  tin_collector            :string
#  total_number_proceedings :string
#
class Opendata::Fssp6 < ApplicationRecord
  self.table_name = :opendata_fssp6
end
