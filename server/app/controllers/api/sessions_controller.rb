module Api
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user!

    def create
      user = User.find_by(email: login_params[:email])
      raise Exceptions::AuthenticationError unless user&.authenticate(login_params[:password])
      raise Exceptions::UnconfirmedUserError unless user.confirmed?

      token = JwtService.encode({ user_id: user.id })
      render json: {
        data: {
          access_token: token,
          expires_in: JwtService.expires_in
        }
      }
    end

    private

    def login_params
      params.require(%i[email password])
      params.permit(:email, :password)
    end
  end
end
