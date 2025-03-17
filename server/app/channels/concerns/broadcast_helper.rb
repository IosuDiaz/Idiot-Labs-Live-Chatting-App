module BroadcastHelper
  def broadcast_to_channel(channel, type, data)
    payload = {
      type: type,
      success: true,
      data: data.deep_stringify_keys,
      is_broadcast: true
    }

    yield(channel, payload)
  end
end
