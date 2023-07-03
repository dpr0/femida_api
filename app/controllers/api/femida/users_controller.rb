# frozen_string_literal: true

class Api::Femida::UsersController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/users', 'api/femida/users?last_name=иванов&first_name=иван&middle_name=иванович'
  def index
    with_error_handling do
      mm_users = MoneymanUser.where(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name])
      fr_user = FemidaRetroUser.find_or_initialize_by(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name])

      byebug
      {
        first_name: fr_user[1],
        middle_name: fr_user[2],
        last_name: fr_user[3],
        phone: fr_user[4],
        birth_date: fr_user[5],
        passport: fr_user[6],
        is_passport_verified: mm_users.find { |x| x[:passport] == fr_user[6] }.present?,
        is_phone_verified: mm_users.find { |x| [x[:phone], "7#{x[:phone]}"].include? fr_user[4] }.present?
      }
    end
  end
end
