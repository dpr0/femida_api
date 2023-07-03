# frozen_string_literal: true

class Api::Femida::UsersController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/users', 'api/femida/users?last_name=иванов&first_name=иван&middle_name=иванович'
  def index
    with_error_handling do
      mm_users = MoneymanUser.where(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name])
      fr_user = FemidaRetroUser.find_by(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name])
      return {} unless fr_user

      passport = mm_users.find { |x| x.passport == fr_user.passport }.present?
      phone = mm_users.find { |x| [x.phone, "7#{x.phone}"].include? fr_user.phone }.present?
      fr_user.update(is_passport_verified: passport, is_phone_verified: phone)
      fr_user
    end
  end
end
