module Terakoya
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    # Use the parent app's authentication
    before_action :authenticate_user! if defined?(Devise)

    helper_method :current_user, :current_partner, :current_leader, :current_mode,
                  :partner_mode?, :leader_mode?, :current_role, :terakoya_root_path

    layout 'terakoya/application'

    private

    def current_partner
      return nil unless respond_to?(:current_user) && current_user

      @current_partner ||= Partner.find_by(
        user_type: current_user.class.name,
        user_id: current_user.id
      )
    end

    def current_leader
      return nil unless respond_to?(:current_user) && current_user

      @current_leader ||= Leader.find_by(
        user_type: current_user.class.name,
        user_id: current_user.id
      )
    end

    def current_mode
      session[:terakoya_mode] ||= default_mode
    end

    def current_role
      case current_mode
      when "partner"
        current_partner
      when "leader"
        current_leader
      else
        current_partner || current_leader
      end
    end

    def partner_mode?
      current_mode == "partner"
    end

    def leader_mode?
      current_mode == "leader"
    end

    def switch_mode(mode)
      if mode.in?(%w[partner leader])
        session[:terakoya_mode] = mode
      end
    end

    def default_mode
      # Default to partner mode if user has a partner profile
      # Otherwise leader mode if they have a leader profile
      return "partner" if current_partner
      return "leader" if current_leader
      "partner"
    end

    def require_partner!
      return if current_partner

      redirect_to new_partner_path, alert: t('terakoya.errors.partner_required')
    end

    def require_leader!
      return if current_leader

      redirect_to new_leader_path, alert: t('terakoya.errors.leader_required')
    end

    def require_role!
      return if current_partner || current_leader

      redirect_to new_partner_path, alert: t('terakoya.errors.role_required')
    end

    def terakoya_root_path
      if current_role
        dashboard_path
      else
        root_path
      end
    end
  end
end
