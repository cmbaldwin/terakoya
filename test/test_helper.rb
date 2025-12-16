ENV["RAILS_ENV"] = "test"
require_relative "../test/dummy/config/environment"
require "rails/test_help"

module Terakoya
  class ActiveSupport::TestCase
    # Setup fixtures for testing
    # fixtures :all

    # Helper methods can go here
    def create_student(attributes = {})
      user = OpenStruct.new(id: 1, class: OpenStruct.new(name: "User"))
      Student.create!(
        {
          user: user,
          display_name: "Test Student",
          preferred_language: "en",
          timezone: "UTC"
        }.merge(attributes)
      )
    end

    def create_project(student, attributes = {})
      Project.create!(
        {
          student: student,
          title: "Test Project",
          description: "A test project",
          goal: "Learn something new",
          status: "planning"
        }.merge(attributes)
      )
    end
  end
end
