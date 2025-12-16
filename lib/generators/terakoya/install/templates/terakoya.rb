# frozen_string_literal: true

Terakoya.configure do |config|
  # The class name of your user model (e.g. "User", "Account")
  config.user_class = "User"

  # The class name of your coach/mentor model (usually same as user_class)
  config.coach_class = "User"

  # A proc that returns coaches from your user class
  # Example: ->(users) { users.where(role: "coach") }
  config.coach_scope = ->(users) { users.where(role: "coach") }

  # The method to call for authentication (e.g. :authenticate_user!)
  config.authentication_method = :authenticate_user!

  # The method to call to get the current user (e.g. :current_user)
  config.current_user_method = :current_user

  # Stylesheet to use (use "application" to use your app's stylesheet)
  # config.stylesheet = "terakoya/application"
end
