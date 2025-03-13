class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :bad_request_response
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

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
end
