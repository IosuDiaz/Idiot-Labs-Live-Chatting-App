module ResponseHelper
  def transmit_success(type, data = {})
    transmit({
      success: true,
      type: type,
      data: data
    })
  end

  def transmit_error(error = {})
    transmit({
      success: false,
      type: "error",
      error: error
    })
  end
end
