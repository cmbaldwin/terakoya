module Terakoya
  class CalendarsController < ApplicationController
    before_action :require_role!
    before_action :set_calendar

    def show
      @events = @calendar.events_for_range(
        params[:start]&.to_datetime || Time.current.beginning_of_month,
        params[:end]&.to_datetime || Time.current.end_of_month
      )

      respond_to do |format|
        format.html
        format.json do
          render json: events_json(@events)
        end
      end
    end

    def edit
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_edit_calendar?
    end

    def update
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_edit_calendar?

      if @calendar.update(calendar_params)
        redirect_to calendar_path, notice: t('terakoya.calendars.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_calendar
      if params[:id]
        @calendar = Calendar.find(params[:id])
      else
        @calendar = current_role&.calendar
      end

      redirect_to dashboard_path, alert: t('terakoya.errors.calendar_not_found') unless @calendar
    end

    def can_edit_calendar?
      @calendar.owner == current_role
    end

    def calendar_params
      params.require(:calendar).permit(
        :name, :timezone, :color, :is_public, :default_event_duration,
        :buffer_time, :advance_booking_days, :minimum_notice_hours,
        settings: {}, work_hours: {}, booking_rules: {}
      )
    end

    def events_json(events)
      events.map do |event|
        if event.full_details_visible_to?(current_role)
          event.as_full_json
        else
          event.as_masked_json
        end
      end
    end
  end
end
