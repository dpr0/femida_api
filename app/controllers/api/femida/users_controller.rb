# frozen_string_literal: true

class Api::Femida::UsersController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/users', 'api/femida/users'
  def index
    with_error_handling do
      FemidaRetroUser.where(is_passport_verified: nil, is_phone_verified: nil).joins('left join moneyman_users m on femida_retro_users.first_name = m.first_name and femida_retro_users.middle_name = m.middle_name and femida_retro_users.last_name = m.last_name')
      FemidaRetroUser.where(is_passport_verified: nil, is_phone_verified: nil).each do |fr_user|
        mm_users = MoneymanUser.where(first_name: fr_user.first_name, middle_name: fr_user.middle_name, last_name: fr_user.last_name).to_a
        next unless fr_user

        passport = mm_users.find { |x| x.passport == fr_user.passport }.present?
        phone = mm_users.find { |x| [x.phone, "7#{x.phone}"].include? fr_user.phone }.present?
        fr_user.update(is_passport_verified: passport, is_phone_verified: phone)
      end
    end
  end

  api :GET, '/users', 'api/femida/users/светлана+анатольевна+демина'
  def show
    with_error_handling do
      first_name, middle_name, last_name = params[:id].split('+')
      mm_users = MoneymanUser.where(first_name: first_name, middle_name: middle_name, last_name: last_name).to_a
      fr_user = FemidaRetroUser.find_by(first_name: first_name, middle_name: middle_name, last_name: last_name)
      return {} unless fr_user

      passport = mm_users.find { |x| x.passport == fr_user.passport }.present?
      phone = mm_users.find { |x| [x.phone, "7#{x.phone}"].include? fr_user.phone }.present?
      fr_user.update(is_passport_verified: passport, is_phone_verified: phone)
      fr_user
    end
  end
end
