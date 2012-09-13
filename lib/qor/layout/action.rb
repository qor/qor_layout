module Qor
  module Layout
    module Action
      def self.detect_action(app)
        Qor::Layout::Configuration.find(:action).map do |action|
          return action if action.block.safe_call(app)
        end
      end
    end
  end
end
