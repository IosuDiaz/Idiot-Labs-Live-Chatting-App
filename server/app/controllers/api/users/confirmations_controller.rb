module Api::Users
  class ConfirmationsController < ApplicationController
    skip_before_action :authenticate_user!, only: :resend_confirmation

    def confirm
      current_user.confirmed? ? raise_already_confirmed_error! : confirm_user
      render json: { message: "¡Account confirmed successfully! You can Login now." }, status: :ok
    end

    def resend_confirmation
      user = User.find_by!(email: email_param)
      raise_already_confirmed_error! if user.confirmed?

      SendConfirmationService.generate(user)
      render json: { message: "¡Confirmation sent! Check your email to finish the sign up." }, status: :ok
    end

    private

    def email_param
      params.require(:email)
    end

    def fetch_auth_token
      params.require(:token)
    end


    def confirm_user
      current_user.update!(confirmed: true)
    end

    def raise_already_confirmed_error!
      raise Exceptions::UserAlreadyConfirmedError
    end
  end
end
