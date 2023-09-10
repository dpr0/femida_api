# frozen_string_literal: true

class AdminController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    @request_count = `grep '=========== Verify REQUEST: ============' log/production.log -c`
  end
end
