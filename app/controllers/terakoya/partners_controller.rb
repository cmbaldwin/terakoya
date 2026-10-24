module Terakoya
  class PartnersController < ApplicationController
    before_action :set_partner, only: [:show, :edit, :update]

    def new
      @partner = Partner.new
    end

    def create
      @partner = Partner.new(partner_params)
      @partner.user = current_user

      if @partner.save
        redirect_to dashboard_path, notice: t('terakoya.partners.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @partner.update(partner_params)
        redirect_to partner_path(@partner), notice: t('terakoya.partners.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_partner
      @partner = current_partner || Partner.find(params[:id])
    end

    def partner_params
      params.require(:partner).permit(
        :display_name, :bio, :goals, :timezone,
        :preferred_language, :status, settings: {}
      )
    end
  end
end
