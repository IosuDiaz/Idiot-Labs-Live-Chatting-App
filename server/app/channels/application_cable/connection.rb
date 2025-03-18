module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    include ResponseHelper

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user&.confirmed?
      send_private_channels_list
    end

    private

    def find_verified_user
      token = request.params[:token] || find_token_from_header
      return unless token

      decoded_token = JwtService.decode(token)
      User.find_by!(id: decoded_token["user_id"])
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
      nil
    end

    def find_token_from_header
      header = request.headers["Authorization"]
      header&.split("Bearer ")&.last
    end

    def send_private_channels_list
      private_channels = current_user.private_channels.pluck(:id)

      transmit_success("private_channels_list", channels: private_channels)
    end
  end
end
