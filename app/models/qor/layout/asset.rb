module Qor
  module Layout
    class Asset < ::ActiveRecord::Base
      self.table_name = 'qor_layout_assets'
      has_drafts(:shadow_id => false) if respond_to?(:has_drafts)

      paperclip_config = Qor::Layout.paperclip_config || {
        :image_path => ":rails_root/public/system/qor_layout_assets/:id/:style.:extension",
        :image_url => "/system/qor_layout_assets/:id/:style.:extension",
      }

      has_attached_file :data, {:path => paperclip_config[:image_path], :url => paperclip_config[:image_url]}.merge(paperclip_config)

      def method_missing(method_sym, *args, &block)
        if data.respond_to?(method_sym)
          return data.send(method_sym, *args)
        end
        super
      end
    end
  end
end
