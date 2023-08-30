# frozen_string_literal: true

class FilesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  def index
    @attachments = ActiveStorage::Attachment.all
  end

  def create
    current_user.attachments.attach(params[:user][:attachment])
    redirect_to files_path
  end

  def destroy
    file = current_user.attachments.find params[:id]
    file.delete
  end
end
