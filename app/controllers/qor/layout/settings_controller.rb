module Qor
  module Layout
    class SettingsController < ApplicationController
      layout false

      def toggle
        inline_editing_qor_layout? ? disable_editing_qor_layout : enable_editing_qor_layout
        redirect_to params[:back] || :back
      end

      def update
        @resource = Qor::Layout::Setting.find_by_id(params[:id])
        @resource.update_attributes(params[:setting])

        if request.xhr?
          render :text => 'ok'
        else
          redirect_to params[:back] || :back
        end
      end

      private
      def inline_editing_qor_layout?
        session[:layout_editing]
      end

      def disable_editing_qor_layout
        session.delete(:layout_editing)
      end

      def enable_editing_qor_layout
        session[:layout_editing] = 1
      end
    end
  end
end
