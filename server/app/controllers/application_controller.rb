class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  attr_reader :current_user

  private

  def bad_request_response(exception)
    render json: { error: exception }, status: :bad_request
  end

  def unprocessable_entity_response(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    return render_error("Access Token is required") unless token

    decoded_token = JwtService.decode(token)

    @current_user = User.find(decoded_token["user_id"])
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    render_error("Authentication Error: #{e.message}")
  end

  def render_error(message)
    render json: { error: message }, status: :unauthorized
  end
end
