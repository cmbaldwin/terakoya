module Terakoya
  class Configuration
    attr_accessor :user_class, :coach_class, :coach_scope,
                  :authentication_method, :current_user_method,
                  :stylesheet

    def initialize
      @user_class = "User"
      @coach_class = "User"
      @coach_scope = ->(users) { users.where(role: "coach") }
      @authentication_method = :authenticate_user!
      @current_user_method = :current_user
      @stylesheet = "terakoya/application"
    end

    def user_class_constantized
      @user_class.constantize
    end

    def coach_class_constantized
      @coach_class.constantize
    end
  end
end
