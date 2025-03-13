module Api::Users
  class ConfirmationsController < ApplicationController
    def confirm
      current_user.confirmed? ? render_already_confirmed_error : confirm_user_account
    end

    private

    def fetch_auth_token
      params.require(:token)
    end


    def confirm_user_account
      current_user.update!(confirmed: true)
      render json: {
        status: "success",
        message: "¡Account confirmed successfully! You can Login now."
      }, status: :ok
    end

    def render_already_confirmed_error
      render json: {
        status: "error",
        code: "already_confirmed",
        message: "The user is already confirmed"
      }, status: :unprocessable_entity
    end
  end
end
