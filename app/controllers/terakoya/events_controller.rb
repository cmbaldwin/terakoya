module Terakoya
  class EventsController < ApplicationController
    before_action :require_role!
    before_action :set_event, only: [:show, :edit, :update, :destroy, :confirm, :cancel]
    before_action :set_calendar, only: [:new, :create]

    def index
      @events = current_role.calendar.events
                           .where("start_time >= ?", params[:start] || Time.current)
                           .order(:start_time)

      respond_to do |format|
        format.html
        format.json do
          render json: @events.map { |e| event_json(e) }
        end
      end
    end

    def show
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_view_event?
    end

    def new
      @event = @calendar.events.build(
        creator: current_role,
        event_type: params[:event_type] || "booking",
        start_time: params[:start_time],
        end_time: params[:end_time]
      )
    end

    def create
      @event = @calendar.events.build(event_params)
      @event.creator = current_role

      # If partner is creating event on leader's calendar, set status to pending
      if partner_mode? && @calendar.owner != current_partner
        @event.status = "pending"
        @event.requires_approval = true
      end

      if @event.save
        # Add creator as participant
        @event.event_participants.create(
          participant: current_role,
          role: "organizer",
          status: "confirmed"
        )

        respond_to do |format|
          format.html { redirect_to calendar_path, notice: t('terakoya.events.created') }
          format.json { render json: event_json(@event), status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_edit_event?
    end

    def update
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_edit_event?

      if @event.update(event_params)
        respond_to do |format|
          format.html { redirect_to event_path(@event), notice: t('terakoya.events.updated') }
          format.json { render json: event_json(@event) }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_delete_event?

      @event.destroy

      respond_to do |format|
        format.html { redirect_to calendar_path, notice: t('terakoya.events.deleted') }
        format.json { head :no_content }
      end
    end

    def confirm
      redirect_to calendar_path, alert: t('terakoya.errors.unauthorized') unless can_approve_event?

      if @event.confirm!
        redirect_to calendar_path, notice: t('terakoya.events.confirmed')
      else
        redirect_to calendar_path, alert: t('terakoya.events.confirm_failed')
      end
    end

    def cancel
      unless can_cancel_event?
        redirect_to calendar_path, alert: t('terakoya.errors.unauthorized')
        return
      end

      if @event.cancel!(reason: params[:reason])
        redirect_to calendar_path, notice: t('terakoya.events.cancelled')
      else
        redirect_to calendar_path, alert: t('terakoya.events.cancel_failed')
      end
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def set_calendar
      if params[:calendar_id]
        @calendar = Calendar.find(params[:calendar_id])
      else
        @calendar = current_role.calendar
      end
    end

    def can_view_event?
      @event.visible_to?(current_role)
    end

    def can_edit_event?
      @event.creator == current_role || @event.calendar.owner == current_role
    end

    def can_delete_event?
      @event.creator == current_role || @event.calendar.owner == current_role
    end

    def can_approve_event?
      leader_mode? && @event.calendar.owner == current_leader && @event.status == "pending"
    end

    def can_cancel_event?
      (@event.creator == current_role || @event.calendar.owner == current_role) &&
        @event.can_be_cancelled?
    end

    def event_params
      params.require(:event).permit(
        :title, :description, :location, :start_time, :end_time,
        :event_type, :visibility, :capacity, :color, :meeting_link,
        :meeting_provider, :join_instructions, :terakoya_class_id,
        :buffer_before, :buffer_after, :cancellation_deadline_hours,
        :requires_approval, :reminder_offset_minutes, :send_email_notifications,
        tags: [], metadata: {}
      )
    end

    def event_json(event)
      if event.full_details_visible_to?(current_role)
        event.as_full_json
      else
        event.as_masked_json
      end
    end
  end
end
