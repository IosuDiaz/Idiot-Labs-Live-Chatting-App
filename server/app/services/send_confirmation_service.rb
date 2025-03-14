class SendConfirmationService
  def self.generate(user)
    payload = { user_id: user.id }
    token = JwtService.encode(payload)

    validation_url = Rails.application.routes.url_helpers.api_users_confirm_url(token: token)
    save_to_file(user.email, validation_url)

    validation_url
  end

  private

  def self.save_to_file(email, validation_url)
    safe_email = email.parameterize(separator: "_")
    filename = "#{safe_email}.txt"

    File.write(
      Rails.root.join("tmp/#{filename}"),
      "Confirm your account: #{validation_url}"
    )
  end
end
