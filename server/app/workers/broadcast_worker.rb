class BroadcastWorker
  include Sidekiq::Worker

  def perform(channel_name, type, data)
    ActionCable.server.broadcast(channel_name, formated_response(type, data))
  rescue StandardError => e
    Rails.logger.error "BroadcastWorker Error: #{e.message} for channel #{channel_name}"
    raise e
  end

  private

  def formated_response(type, data)
    {
      type: type,
      success: true,
      data: data.deep_stringify_keys,
      is_broadcast: true
    }
  end
end
