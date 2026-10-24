module Terakoya
  class LeadersController < ApplicationController
    before_action :set_leader, only: [:show, :edit, :update]

    def new
      @leader = Leader.new
    end

    def create
      @leader = Leader.new(leader_params)
      @leader.user = current_user

      if @leader.save
        redirect_to dashboard_path, notice: t('terakoya.leaders.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @leader.update(leader_params)
        redirect_to leader_path(@leader), notice: t('terakoya.leaders.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_leader
      @leader = current_leader || Leader.find(params[:id])
    end

    def leader_params
      params.require(:leader).permit(
        :display_name, :bio, :timezone, :preferred_language,
        :accepting_partners, :max_partners, :status,
        expertise: [], settings: {}, availability_rules: {}
      )
    end
  end
end
