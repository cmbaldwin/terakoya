module Terakoya
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :authenticate_user!
    helper_method :current_student, :current_coach?, :terakoya_root_path

    layout "terakoya/application"

    private

    def authenticate_user!
      send(Terakoya.config.authentication_method) if Terakoya.config.authentication_method
    end

    def current_user
      send(Terakoya.config.current_user_method) if Terakoya.config.current_user_method
    end

    def current_student
      @current_student ||= Student.find_by(
        user_type: current_user.class.name,
        user_id: current_user.id
      )
    end

    def current_coach?
      return false unless current_user

      scope = Terakoya.config.coach_scope
      scope.call(Terakoya.config.user_class_constantized.where(id: current_user.id)).exists?
    end

    def require_student!
      unless current_student
        redirect_to new_student_path, alert: t("terakoya.errors.student_required")
      end
    end

    def terakoya_root_path
      if current_student
        dashboard_path
      else
        root_path
      end
    end
  end
end
