module Qor
  module Layout
    class Engine < ::Rails::Engine
      rake_tasks do
        require File.join(File.dirname(__FILE__), 'tasks')
      end

      config.to_prepare do
        ApplicationController.helper Qor::Layout::LayoutHelper
      end
    end
  end
end
