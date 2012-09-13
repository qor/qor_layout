module Qor
  module Layout
    module Action
      def self.detect_action(app)
        Qor::Layout::Configuration.actions.values.map do |action|
          return action if action.detect_blk.safe_call(app)
        end
      end
    end
  end
end
