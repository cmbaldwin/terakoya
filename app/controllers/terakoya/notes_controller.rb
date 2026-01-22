module Terakoya
  class NotesController < ApplicationController
    before_action :require_role!
    before_action :set_note, only: [:show, :edit, :update, :destroy, :publish]
    before_action :authorize_note!, only: [:edit, :update, :destroy, :publish]

    def index
      @notes = Note.published.visible_to_public

      # Filter by class if specified
      if params[:terakoya_class_id].present?
        @class = Terakoya::Class.find(params[:terakoya_class_id])
        @notes = @notes.for_class(@class)

        # If user is member/leader of class, show all notes
        if can_view_class_notes?(@class)
          @notes = Note.for_class(@class).where(visibility: ['public', 'shared_with_class'])
        end
      end

      # Filter by event if specified
      if params[:event_id].present?
        @event = Event.find(params[:event_id])
        @notes = @notes.for_event(@event) if @event.visible_to?(current_role)
      end

      # Show user's own notes
      if params[:my_notes] == 'true'
        @notes = current_role.notes
      end

      @notes = @notes.recent.page(params[:page]).per(20)
    end

    def show
      unless @note.visible_to?(current_role)
        redirect_to notes_path, alert: t('terakoya.errors.unauthorized')
      end
    end

    def new
      @note = current_role.notes.build
      @note.terakoya_class_id = params[:terakoya_class_id] if params[:terakoya_class_id]
      @note.event_id = params[:event_id] if params[:event_id]
    end

    def create
      @note = current_role.notes.build(note_params)

      if @note.save
        if params[:publish]
          @note.publish!
          redirect_to @note, notice: t('terakoya.notes.published')
        else
          redirect_to @note, notice: t('terakoya.notes.created')
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @note.update(note_params)
        if params[:publish] && @note.draft?
          @note.publish!
          redirect_to @note, notice: t('terakoya.notes.published')
        else
          redirect_to @note, notice: t('terakoya.notes.updated')
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @note.destroy
      redirect_to notes_path, notice: t('terakoya.notes.deleted')
    end

    def publish
      if @note.publish!
        redirect_to @note, notice: t('terakoya.notes.published')
      else
        redirect_to @note, alert: t('terakoya.notes.publish_failed')
      end
    end

    private

    def set_note
      @note = Note.find(params[:id])
    end

    def authorize_note!
      unless @note.editable_by?(current_role)
        redirect_to notes_path, alert: t('terakoya.errors.unauthorized')
      end
    end

    def can_view_class_notes?(klass)
      return true if leader_mode? && klass.leader == current_leader
      return true if partner_mode? && klass.partners.include?(current_partner)
      false
    end

    def note_params
      params.require(:note).permit(
        :title, :content, :visibility, :status,
        :terakoya_class_id, :event_id, :notable_type, :notable_id,
        tags: []
      )
    end
  end
end
