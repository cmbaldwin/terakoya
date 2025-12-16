# frozen_string_literal: true

module Terakoya
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Terakoya initializer and copy locale files to your application."

      def copy_initializer
        template "terakoya.rb", "config/initializers/terakoya.rb"
      end

      def mount_engine
        route "mount Terakoya::Engine => '/terakoya'"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
