module Qor
  module Layout
    module Configuration
      class Inputs
        include Qor::Extlib::Dsl::Configuration::InputMeta
      end

      class RawData
        include Qor::Extlib::Dsl::Configuration::RawData
        attr_accessor :description, :description_blk, :meta_inputs, :template_blk, :context_blk, :detect_blk

        def layout(name, options = {}, &blk)
          Qor::Layout::Configuration::Layout.new(blk, self.owner, options.merge(:name => name))
        end

        def gadget(name, options = {}, &blk)
          Qor::Layout::Configuration::Gadget.new(blk, self.owner, options.merge(:name => name))
        end

        def action(name, options = {}, &blk)
          ::Qor::Layout::Configuration::Action.new(blk, self.owner, options.merge(:name => name))
        end

        def gadgets(name, options = {}, &blk)
          # TODO define gadgets for layout
        end

        def settings(&blk)
          self.meta_inputs = Inputs.new
          self.meta_inputs.instance_eval(&blk)
          self.meta_inputs
        end

        def context(&blk)
          self.context_blk = blk
        end

        def template(&blk)
          self.template_blk = blk
        end

        def detect(&blk)
          self.detect_blk = blk
        end

        def desc(description = nil, &blk)
          raise 'desc must be string or blcok' unless description.is_a?(String) || blk
          self.description = description
          self.description_blk = blk
        end
      end

      class Base
        include Qor::Extlib::Dsl::Configuration::Base
        attr_accessor :name, :floating

        self.raw_data_klazz = ::Qor::Layout::Configuration::RawData
        def initialize(*arguments)
          super

          root = arguments[1]

          if root
            root.group_children ||= {}
            root.group_children[self.class.to_s] ||= {}
            root.group_children[self.class.to_s][self.name.to_s] = self
          end
        end

        def child_key
          File.join(self.class.to_s, self.name.to_s)
        end

        def description
          self.raw_data.description || self.raw_data.description_blk.try(:call)
        end
      end

      class Root < Base
        attr_accessor :group_children

        def layouts(name=nil)
          children = group_children[Layout.to_s]
          children = children[name] if name.present?
          children
        end

        def gadgets(name=nil)
          children = group_children[Gadget.to_s]
          children = children[name] if name.present?
          children
        end

        def gadget_by_name(name)
          Qor::Layout::Configuration.gadgets.with_indifferent_access[name]
        end

        def gadget_settings_by_name(name)
          (gadget_by_name(name).try(:settings) || {}).with_indifferent_access
        end

        def actions(name=nil)
          children = group_children[Action.to_s]
          children = children[name] if name.present?
          children
        end
      end

      class Layout < Base
      end
      class Gadget < Base
        def settings
          self.raw_data.meta_inputs.meta_hash.inject({}) do |s, v|
            s.update({v[0] => {:label => (v[1].with_indifferent_access[:name] || v[0]).to_s}.merge(v[1])})
          end
        end

        def context_blk
          self.raw_data.context_blk
        end

        def template
          self.raw_data.template_blk.call
        end
      end
      class Action < Base
        def detect_blk
          self.raw_data.detect_blk
        end
      end

      class << self
        def load(path="config/layout.rb")
          @root = Qor::Extlib::Dsl::Configuration.load(::Qor::Layout::Configuration::Root, path)
        end

        def root
          @root ||= load
        end

        delegate :layouts, :gadgets, :actions, :gadget_by_name, :gadget_settings_by_name, :to => :root
      end
    end
  end
end
