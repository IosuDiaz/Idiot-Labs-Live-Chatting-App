class JwtService
  SECRET = Rails.application.secret_key_base
  EXPIRATION_HOURS = Rails.configuration.x.jwt.expiration_hours || 24
  ALGORITHM = "HS256".freeze

  def self.encode(payload)
    payload[:exp] = EXPIRATION_HOURS.hours.from_now.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, { algorithm: ALGORITHM, verify_expiration: true }).first
  end

  def self.expires_in
    EXPIRATION_HOURS.hours.to_i
  end
end
