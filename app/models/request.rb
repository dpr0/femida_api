# frozen_string_literal: true

# == Schema Information
#
# Table name: requests
#
#  id          :bigint           not null, primary key
#  birth_date  :string
#  first_name  :string
#  info        :string
#  last_name   :string
#  middle_name :string
#  phone       :string
#  response    :string
#  service     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_requests_on_phone  (phone)
#
class Request < ApplicationRecord

  OKB_LOST_REQUESTS = 74016
  OKB_IMPORT_DATE = '2023-09-11 04:00:00'

end
