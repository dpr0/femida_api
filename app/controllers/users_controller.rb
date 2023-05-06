# frozen_string_literal: true

class UsersController < ApplicationController
  protect_from_forgery with: :null_session
  # before_action :doorkeeper_authorize! # -> { doorkeeper_authorize! :read, :write }

  def index
    head(:ok)
  end

  def show; end

  private

  def current_user
    @user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def render_status(payload = {})
    json = { request_id: request.headers['X-Request-Id'], payload: payload }
    Rails.logger.info JSON.pretty_generate(json)
    render status: :ok, json: json
  end
end
