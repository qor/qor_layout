module Qor
  module Layout
    module LayoutHelper
      def render_layout(name)
        html = Qor::Layout::Layout.detect_layout(name, self).try(:render, session[:layout_editing]).to_s

        if session[:layout_editing]
          html += <<-STRING
          <script class='qor_layout_script'>
            $(document).ready(function() {
              qlayout = qLayout.init($('script.qor_layout_script').parent()[0]);
            });
          </script>
          STRING
        end

        html.html_safe
      end
    end
  end
end

