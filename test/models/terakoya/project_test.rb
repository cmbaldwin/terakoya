require "test_helper"

module Terakoya
  class ProjectTest < ActiveSupport::TestCase
    test "project requires student" do
      project = Project.new(title: "Test")
      assert_not project.valid?
      assert_includes project.errors[:student], "must exist"
    end

    test "project requires title" do
      student = create_student
      project = Project.new(student: student)
      assert_not project.valid?
      assert_includes project.errors[:title], "can't be blank"
    end

    test "project has default status of planning" do
      student = create_student
      project = Project.create!(student: student, title: "Test")
      assert_equal "planning", project.status
    end

    test "project can transition through statuses" do
      student = create_student
      project = create_project(student)

      assert_equal "planning", project.status

      project.start!
      assert_equal "active", project.status
      assert_not_nil project.started_at

      project.pause!
      assert_equal "paused", project.status

      project.resume!
      assert_equal "active", project.status

      project.complete!
      assert_equal "completed", project.status
      assert_not_nil project.completed_at
    end

    test "project calculates duration correctly" do
      student = create_student
      project = create_project(student)

      assert_nil project.duration

      project.update!(started_at: 5.days.ago)
      assert_equal 5, project.duration

      project.update!(completed_at: 2.days.ago)
      assert project.duration <= 3
    end

    test "in_progress? returns correct status" do
      student = create_student
      project = create_project(student)

      assert project.in_progress?

      project.complete!
      assert_not project.in_progress?

      project.update!(status: "archived")
      assert_not project.in_progress?
    end
  end
end
