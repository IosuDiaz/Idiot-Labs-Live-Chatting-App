class Api::RegistrationsController < ApplicationController
  def create
    user = User.create!(user_params)

    render json: {
      status: "success",
      message: "Usuario registrado. Revisa tu email para validar la cuenta.",
      data: { email: user.email }
    }, status: :created
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :nickname)
  end
end
