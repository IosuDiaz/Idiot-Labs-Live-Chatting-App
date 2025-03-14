class Api::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  def create
    user = User.create!(user_params)

    render json: {
      message: "Signed up successfully. Check your email to cofirm the user.",
      data: { email: user.email }
    }, status: :created
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :nickname)
  end
end
