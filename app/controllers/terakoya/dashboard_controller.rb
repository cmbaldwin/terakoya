module Terakoya
  class DashboardController < ApplicationController
    before_action :require_role!

    def show
      if partner_mode?
        show_partner_dashboard
      elsif leader_mode?
        show_leader_dashboard
      else
        redirect_to new_partner_path, alert: t('terakoya.errors.role_required')
      end
    end

    def switch_mode
      new_mode = params[:mode]
      if new_mode.in?(%w[partner leader])
        session[:terakoya_mode] = new_mode
        redirect_to dashboard_path, notice: t('terakoya.mode.switched', mode: new_mode.capitalize)
      else
        redirect_to dashboard_path, alert: t('terakoya.mode.invalid')
      end
    end

    private

    def show_partner_dashboard
      @partner = current_partner
      @classes = @partner.active_classes
      @upcoming_events = @partner.upcoming_events.limit(10)
      @pending_bookings = @partner.pending_bookings.limit(5)
      @calendar = @partner.calendar

      render :partner_dashboard
    end

    def show_leader_dashboard
      @leader = current_leader
      @classes = @leader.classes.active
      @upcoming_events = @leader.upcoming_events.limit(10)
      @pending_approvals = @leader.pending_approvals.limit(10)
      @calendar = @leader.calendar
      @total_partners = @leader.current_partners_count

      render :leader_dashboard
    end
  end
end
