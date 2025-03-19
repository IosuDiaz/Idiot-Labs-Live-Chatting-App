module Api::Users
  class UsersController < ApplicationController
    def show
      raise_not_confirmed_error! unless current_user.confirmed?
      render json: UserPresenter.new(current_user).to_h, status: :ok
    end

    private

    def raise_not_confirmed_error!
      raise Exceptions::UserNotConfirmedError
    end
  end
end
