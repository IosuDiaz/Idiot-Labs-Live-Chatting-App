class JwtService
  SECRET = Rails.application.secret_key_base
  ALGORITHM = "HS256".freeze

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, { algorithm: ALGORITHM }).first
  rescue JWT::DecodeError
    nil
  end
end
