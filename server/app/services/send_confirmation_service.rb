class SendConfirmationService
  def self.generate(user)
    payload = { user_id: user.id }
    token = JwtService.encode(payload)

    confirmation_url = Rails.application.routes.url_helpers.api_users_confirm_url(token: token)
    save_to_file(user.email, confirmation_url)
  end

  private

  def self.save_to_file(email, confirmation_url)
    safe_email = email.parameterize(separator: "_")
    filename = "#{safe_email}.txt"

    File.write(
      Rails.root.join("tmp/#{filename}"),
      "Confirm your account: #{confirmation_url}"
    )
  end
end
