# frozen_string_literal: true

# == Schema Information
#
# Table name: opendata_fsrar
#
#  id                        :bigint           not null, primary key
#  address_1                 :string
#  address_2                 :string
#  change_date               :string
#  coords                    :string
#  doc_num                   :string
#  email                     :string
#  inn                       :string
#  kind                      :string
#  kpp                       :string
#  kpp_2                     :string
#  license_from              :string
#  license_info              :string
#  license_info_basis        :string
#  license_info_history      :string
#  license_info_updated_date :string
#  license_num               :string
#  license_organ             :string
#  license_to                :string
#  name                      :string
#  product_type              :string
#  reestr_num                :string
#  region_code               :string
#  region_code_2             :string
#  service_date              :string
#  service_info              :string
#
class Opendata::Fsrar < ApplicationRecord
  self.table_name = :opendata_fsrar
end
