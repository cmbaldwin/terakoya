module Terakoya
  class Engine < ::Rails::Engine
    isolate_namespace Terakoya

    # Importmap integration
    initializer "terakoya.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    # Stimulus controllers
    initializer "terakoya.stimulus" do |app|
      if app.config.respond_to?(:stimulus)
        app.config.stimulus.paths << root.join("app/javascript/terakoya/controllers")
      end
    end

    # Assets
    initializer "terakoya.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[terakoya/application.css]
      end
    end

    # Action Text support
    initializer "terakoya.action_text" do
      ActiveSupport.on_load(:action_text_rich_text) do
        # Rich text configuration will go here
      end
    end

    # Zeitwerk configuration
    config.autoload_paths = %W[
      #{root}/app/controllers
      #{root}/app/models
      #{root}/app/helpers
    ]

    # Enable eager loading for production
    config.eager_load_paths = config.autoload_paths.dup
  end
end
