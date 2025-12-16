module Terakoya
  class StudentsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:new, :create]
    before_action :set_student, only: [:show, :edit, :update]

    def new
      @student = Student.new
    end

    def create
      @student = Student.new(student_params)
      @student.user = current_user

      if @student.save
        redirect_to dashboard_path, notice: t("terakoya.students.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      if @student.update(student_params)
        redirect_to student_path(@student), notice: t("terakoya.students.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_student
      @student = Student.find(params[:id])
    end

    def student_params
      params.require(:student).permit(
        :display_name,
        :preferred_language,
        :bio,
        :goals,
        :timezone,
        preferences: {}
      )
    end
  end
end
