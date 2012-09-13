module Qor
  module Layout
    class Setting < ::ActiveRecord::Base
      self.table_name = 'qor_layout_settings'
      attr_accessor :destroy_value_attributes

      has_drafts :custom_associations => :related_records if respond_to?(:has_drafts)

      serialize :value
      serialize :style

      default_values :value => {}, :style => {:top => '1px', :left => '1px'}

			belongs_to :layout,  :class_name => "Qor::Layout::Layout"
			belongs_to :parent,  :class_name => "Qor::Layout::Setting"
			has_many   :children,:class_name => "Qor::Layout::Setting", :foreign_key => :parent_id
      accepts_nested_attributes_for :children, :allow_destroy => true

      before_save :assign_serialized_attributes
      def assign_serialized_attributes
        self.value = @value_attributes unless @value_attributes.nil?
        self.style = @style_attributes unless @style_attributes.nil?

        new_value = self.value
        (self.destroy_value_attributes || {}).map do |key, value|
          new_value = new_value.reject {|k,v| k.to_s == key.to_s } if value == "1"
        end
        self.value = new_value
      end

      def values(name, for_setting=false)
        stored_value   = (value || {}).with_indifferent_access[name]
        gadget_setting = gadget_settings.find(:meta, name)

        if stored_value =~ /^([\w:]+)\((\d+)\)$/
          return ($1.constantize.find_by_id($2) rescue stored_value)
        elsif gadget_setting && (gadget_setting.options[:type].to_s == 'gadget')
          gadget_name = gadget_setting.options[:name] || name
          gadgets = children.where(:name => gadget_name)
          return (for_setting ? gadgets.map(&:settings) : gadgets)
        else
          return stored_value
        end
      end

      def meta_settings
        gadget_settings.children.inject({}) do |s, setting|
          value = values(setting.name, true)
          s.merge({setting.name => value})
        end.with_indifferent_access
      end

      def related_records
        settings.respond_to?(:values) ? settings.values.select {|x| x.is_a? ActiveRecord::Base } : []
      end

      def value_attributes=(attrs)
        attrs       = attrs.with_indifferent_access
        value_attrs = {}
        gadget_settings.find(:meta).map do |child|
          key = child.name

          if child.options[:type].to_s =~ /image|file|media/
            if self.value && (self.value[key] =~ /^([\w:]+)\((\d+)\)$/)
              asset = $1.constantize.find_by_id($2).update_attribute(:data, attrs[key]) if attrs[key]
              value_attrs.update({key => self.value[key]})
            elsif attrs[key]
              asset = Qor::Layout::Asset.create(:data => attrs[key])
              value_attrs.update({key => "Qor::Layout::Asset(#{asset.id})"})
            end
          elsif attrs[key]
            value_attrs.update({key => attrs[key]})
          end
        end
        old_value = (self.value || {}).symbolize_keys
        @value_attributes = old_value.merge(value_attrs.symbolize_keys)
      end

      def style_attributes=(attrs)
        old_style = self.style.symbolize_keys
        new_style = old_style.merge(attrs.symbolize_keys || {})
        @style_attributes = new_style
      end

      def children_attributes=(attrs)
        attrs.map do |key, atts|
          child = children.find_by_id(atts.delete("id"))
          if atts.delete("_destroy").to_s == "1"
            child.try(:destroy)
          elsif child
            child.update_attributes(atts)
          else
            child_attrs = atts['value_attributes']
            children.new(atts) if child_attrs.keys.any? {|k| child_attrs[k].present? }
          end
        end
      end

      def settings
        if gadget.first(:context).try(:block)
          self.instance_eval &gadget.first(:context).try(:block)
        else
          meta_settings
        end
      end

      def resource_attributes_for_settings
        attrs = []
        gadget_settings.children.map do |child|
          attr_show = !child.options[:hidden]
          attrs << Qor::ResourceAttribute.new("value_attributes[#{child.name}]", child.options) if attr_show
        end
        attrs
      end

      def render_without_style
        ::Mustache.render(gadget.first(:template).try(:value).to_s, settings)
      end

			def render(edit_mode=false)
        parse_content = Nokogiri::HTML::DocumentFragment.parse(render_without_style)
        old_style_css = parse_content.xpath('*').first.attribute("style").to_s
        old_style     = old_style_css.split(";").inject({}) {|s, v| s.merge(Hash[*v.split(":").map(&:strip)]) }
        new_style     = old_style.merge(style)
        style_css     = new_style.map {|k,v| "#{k}: #{v}"}.join("; ")

        parse_content.xpath('*').first.set_attribute("qor_layout_elements", id.to_s)
        parse_content.xpath('*').first.set_attribute("qor_layout_draggable_elements", id.to_s) if gadget.options[:floating]
        parse_content.xpath('*').first.set_attribute("style", style_css)
        extra = edit_mode ? "<div for_qor_layout_elements='#{id}'><a href='/admin/layout_settings/#{id}/edit'><img src='/qor_widget/images/settings.png'/></a></div>" : ""

        parse_content.to_xhtml + extra
			end

      def gadget
        Qor::Layout::Configuration.find(:gadget, name)
      end

      def gadget_settings
        gadget.first(:settings)
      end

      def method_missing(method_sym, *args, &block)
        if method_sym.to_s =~ /^value_attributes\[(\w+)\]$/
          return self.values($1)
        end
        super
      end
    end
  end
end
