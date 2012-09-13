module Qor
  module Layout
    class Layout < ::ActiveRecord::Base
      self.table_name = 'qor_layout_layouts'

      has_many :settings, :class_name => "Qor::Layout::Setting"

      def self.detect_layout(name, app=nil)
        scope  = where(:name => name)
        action = Qor::Layout::Action.detect_action(app)
        scope.where(:action_name => action.try(:name)).first || scope.first
      end

      def render(edit_mode=false)
        settings.map {|setting| setting.render(edit_mode) }.join("")
      end
    end
  end
end
