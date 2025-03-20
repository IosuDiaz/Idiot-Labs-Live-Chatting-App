module Api::Users
  class UsersController < ApplicationController
    def show
      raise_not_confirmed_error! unless current_user.confirmed?
      render json: { data: user_presenter }, status: :ok
    end

    private

    def user_presenter
      UserPresenter.new(current_user).to_h
    end

    def raise_not_confirmed_error!
      raise Exceptions::UserNotConfirmedError
    end
  end
end
