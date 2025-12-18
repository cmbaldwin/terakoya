module Terakoya
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    # Use the parent app's authentication
    before_action :authenticate_user! if defined?(Devise)

    helper_method :current_student, :current_coach?, :terakoya_root_path

    layout 'terakoya/application'

    private

    def current_student
      return nil unless respond_to?(:current_user) && current_user

      @current_student ||= Student.find_by(
        user_type: current_user.class.name,
        user_id: current_user.id
      )
    end

    def current_coach?
      return false unless respond_to?(:current_user) && current_user

      # For now, simplified - can be configured later
      current_user.respond_to?(:role) && current_user.role == 'coach'
    end

    def require_student!
      return if current_student

      redirect_to new_student_path, alert: t('terakoya.errors.student_required')
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
