module Terakoya
  class DashboardController < ApplicationController
    before_action :require_student!

    def show
      @student = current_student
      @active_projects = @student.active_projects
      @completed_projects = @student.completed_projects
      @recent_messages = Message.joins(:project)
                                .where(projects: { student_id: @student.id })
                                .order(created_at: :desc)
                                .limit(5)
    end
  end
end
