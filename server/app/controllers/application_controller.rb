class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from Exceptions::UserNotConfirmedError, with: :user_not_confirmed
  rescue_from Exceptions::AuthenticationError, with: :invalid_credentials
  rescue_from Exceptions::UserAlreadyConfirmedError, with: :user_already_confirmed
  rescue_from Exceptions::TokenNotFoundError, with: :token_missing

  attr_reader :current_user

  private

  def token_missing(error)
    render_error(error, :unauthorized)
  end

  def user_not_confirmed(error)
    render_error(error, :bad_request)
  end

  def user_already_confirmed(error)
    render_error(error, :unprocessable_entity)
  end

  def invalid_credentials(error)
    render_error(error, :unauthorized)
  end

  def bad_request_response(error)
    render_error(error, :bad_request)
  end

  def unprocessable_entity_response(exception)
    render json: { errors: exception.record.errors.messages }, status: :unprocessable_entity
  end

  def not_found_response(error)
    render_error(error, :not_found)
  end

  def authenticate_user!
    token = fetch_auth_token
    raise Exceptions::TokenNotFoundError unless token

    decoded_token = JwtService.decode(token)

    @current_user = User.find(decoded_token["user_id"])
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    render_error(e, :unauthorized)
  end

  def fetch_auth_token
    request.headers["Authorization"]&.split(" ")&.last
  end

  def render_error(error, status)
    error_response = { error: { message: error.message, code: error_code_or_nil(error) }.compact }
    render json: error_response, status: status
  end

  def error_code_or_nil(error)
    error.respond_to?(:code) ? error.code : nil
  end
end
