class UserPresenter
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def to_h
    {
      id: user.id,
      nickname: user.nickname
    }
  end
end
