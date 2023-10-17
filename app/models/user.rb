# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string
#  phone                  :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  token                  :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :trackable, :recoverable, :rememberable, :validatable
  has_many :authorizations, dependent: :destroy
  has_many :user_roles
  has_many_attached :attachments

  def self.auth_by_token(headers)
    return unless headers['Authorization'].present?

    hash = JsonWebToken.decode(headers['Authorization'].split(' ').last)
    return if Time.at(hash['exp']) < Time.now

    @current_user = User.find(hash[:user_id]) if hash && hash[:user_id]
  end

  def find_for_oauth
    auth = authorizations.where(provider: provider, uid: uid).first
    return auth.user if auth

    authorizations.create(provider: provider, uid: uid)
  end
end
