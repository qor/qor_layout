require 'qor_dsl'

module Qor
  module Layout
    module Configuration
      include Qor::Dsl
      default_configs ["config/qor/layout.rb", "config/layout.rb"]

      node :template

      node :gadget do
        node :desc

        node :settings do
          node :meta
        end

        node :context
        node :template, :inherit => true
      end

      node :layout do
        node :gadgets
      end

      node :action do
        node :desc
        node :detect
      end
    end
  end
end
