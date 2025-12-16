require "test_helper"

module Terakoya
  class StudentTest < ActiveSupport::TestCase
    test "student requires display_name" do
      user = OpenStruct.new(id: 1, class: OpenStruct.new(name: "User"))
      student = Student.new(user: user)
      assert_not student.valid?
      assert_includes student.errors[:display_name], "can't be blank"
    end

    test "student has default preferred_language" do
      user = OpenStruct.new(id: 1, class: OpenStruct.new(name: "User"))
      student = Student.create!(
        user: user,
        display_name: "Test",
        timezone: "UTC"
      )
      assert_equal "en", student.preferred_language
    end

    test "student has default timezone" do
      user = OpenStruct.new(id: 1, class: OpenStruct.new(name: "User"))
      student = Student.create!(
        user: user,
        display_name: "Test"
      )
      assert_equal "UTC", student.timezone
    end

    test "student can have multiple projects" do
      student = create_student
      project1 = create_project(student, title: "Project 1")
      project2 = create_project(student, title: "Project 2")

      assert_equal 2, student.projects.count
      assert_includes student.projects, project1
      assert_includes student.projects, project2
    end

    test "active_projects returns only planning and active projects" do
      student = create_student
      active_project = create_project(student, title: "Active", status: "active")
      planning_project = create_project(student, title: "Planning", status: "planning")
      completed_project = create_project(student, title: "Completed", status: "completed")

      assert_equal 2, student.active_projects.count
      assert_includes student.active_projects, active_project
      assert_includes student.active_projects, planning_project
      assert_not_includes student.active_projects, completed_project
    end

    test "completed_projects returns only completed projects" do
      student = create_student
      active_project = create_project(student, title: "Active", status: "active")
      completed_project = create_project(student, title: "Completed", status: "completed")

      assert_equal 1, student.completed_projects.count
      assert_includes student.completed_projects, completed_project
      assert_not_includes student.completed_projects, active_project
    end
  end
end
