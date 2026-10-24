module Terakoya
  class ClassesController < ApplicationController
    before_action :require_role!
    before_action :set_class, only: [:show, :edit, :update, :destroy, :join, :leave]
    before_action :require_leader_for_management, only: [:edit, :update, :destroy]

    def index
      if leader_mode?
        @classes = current_leader.classes.not_archived
      else
        @classes = current_partner.classes
      end
    end

    def show
      @members = @class.active_partners.includes(:user)
      @upcoming_events = @class.upcoming_events.limit(10)
      @recent_notes = @class.notes.published.recent.limit(5)
    end

    def new
      redirect_to classes_path, alert: t('terakoya.errors.leader_required') unless current_leader
      @class = current_leader.classes.build
    end

    def create
      redirect_to classes_path, alert: t('terakoya.errors.leader_required') unless current_leader

      @class = current_leader.classes.build(class_params)

      if @class.save
        redirect_to terakoya_class_path(@class), notice: t('terakoya.classes.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @class.update(class_params)
        redirect_to terakoya_class_path(@class), notice: t('terakoya.classes.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @class.update(status: "archived", archived_at: Time.current)
      redirect_to classes_path, notice: t('terakoya.classes.archived')
    end

    def join
      if current_partner && @class.add_partner(current_partner)
        redirect_to terakoya_class_path(@class), notice: t('terakoya.classes.joined')
      else
        redirect_to terakoya_class_path(@class), alert: t('terakoya.classes.join_failed')
      end
    end

    def leave
      if current_partner && @class.remove_partner(current_partner)
        redirect_to classes_path, notice: t('terakoya.classes.left')
      else
        redirect_to terakoya_class_path(@class), alert: t('terakoya.classes.leave_failed')
      end
    end

    private

    def set_class
      @class = Terakoya::Class.find_by(slug: params[:id]) || Terakoya::Class.find(params[:id])
    end

    def require_leader_for_management
      unless @class.leader == current_leader
        redirect_to terakoya_class_path(@class), alert: t('terakoya.errors.unauthorized')
      end
    end

    def class_params
      params.require(:terakoya_class).permit(
        :name, :description, :status, :capacity, :meeting_schedule,
        :timezone, :color, :visibility, :starts_at, :ends_at,
        settings: {}
      )
    end
  end
end
