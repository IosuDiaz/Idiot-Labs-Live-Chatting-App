module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_internal_error
  end

  private

  def handle_internal_error(exception)
    Rails.logger.error "Cable Error: #{exception.message}\n#{exception.backtrace.join("\n")}"
    transmit_error(type: "internal_error", message: "Something went wrong", code: 500)
  end

  def transmit_error(details)
    transmit({
      type: "error",
      error: details
    })
  end
end
