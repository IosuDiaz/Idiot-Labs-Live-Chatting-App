module Exceptions
  class AuthenticationError < StandardError
    def initialize(message = "Invalid Credentials.")
      super
    end
  end

  class UnconfirmedUserError < StandardError
    def initialize(message = "User not confirmed.")
      super
    end
  end
end
