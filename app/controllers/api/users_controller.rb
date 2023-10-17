# frozen_string_literal: true

class Api::UsersController < ApplicationController
  protect_from_forgery with: :null_session

  def show; end

  def login
    @user = User.where(email: params[:email]).first
    render(json: { error: 'Not Authorized' }, status: :unauthorized) and return unless @user&.persisted? && @user&.valid_password?(params[:password])

    auth = @user.find_for_oauth
    render(json: { error: 'Not Authorized' }, status: :unauthorized) and return unless auth&.persisted?

    sign_in @user, event: :authentication

    roles = @user.user_roles.map(&:role).compact
    render json: { id: current_user.id, auth_token: JsonWebToken.encode(user_id: current_user.id), roles: roles }
  end
end
