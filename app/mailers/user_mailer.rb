# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: "notifications@#{ENV['HOST']}"

  def invite_email
    mail(to: params[:user].email, subject: "Вы приглашены на #{ENV['HOST']}")
  end
end
