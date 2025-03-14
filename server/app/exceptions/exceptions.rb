module Exceptions
  class AuthenticationError < StandardError
    def initialize(message = "Invalid Credentials.")
      super
    end
  end

  class UserNotConfirmedError < StandardError
    attr_reader :code
    def initialize(message = "User not confirmed.", code = :user_not_confirmed)
      @code = code
      super(message)
    end
  end

  class UserAlreadyConfirmedError < StandardError
    def initialize(message = "User is already confirmed.")
      super
    end
  end

  class TokenNotFoundError < StandardError
    def initialize(message = "Token is missing.")
      super
    end
  end
end
