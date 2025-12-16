module Terakoya
  class ProjectsController < ApplicationController
    before_action :require_student!, except: [:index]
    before_action :set_project, only: [:show, :edit, :update, :destroy, :start, :pause, :resume, :complete]

    def index
      @projects = current_student&.projects&.recent || Project.none
    end

    def show
    end

    def new
      @project = current_student.projects.build
    end

    def create
      @project = current_student.projects.build(project_params)

      if @project.save
        redirect_to project_path(@project), notice: t("terakoya.projects.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @project.update(project_params)
        redirect_to project_path(@project), notice: t("terakoya.projects.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @project.destroy
      redirect_to projects_path, notice: t("terakoya.projects.deleted")
    end

    # State transition actions
    def start
      @project.start!
      redirect_to project_path(@project), notice: t("terakoya.projects.started")
    end

    def pause
      @project.pause!
      redirect_to project_path(@project), notice: t("terakoya.projects.paused")
    end

    def resume
      @project.resume!
      redirect_to project_path(@project), notice: t("terakoya.projects.resumed")
    end

    def complete
      @project.complete!
      redirect_to project_path(@project), notice: t("terakoya.projects.completed")
    end

    private

    def set_project
      @project = current_student.projects.find(params[:id])
    end

    def project_params
      params.require(:project).permit(
        :title,
        :description,
        :goal,
        :deliverable,
        :target_date,
        metadata: {}
      )
    end
  end
end
