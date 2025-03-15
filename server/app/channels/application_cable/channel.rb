module ApplicationCable
  class Channel < ActionCable::Channel::Base
    include ErrorHandler

    def perform(action, data)
      super
    rescue => e
      rescue_with_handler(e) || raise
    end
  end
end
