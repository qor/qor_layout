Dir[File.join(File.dirname(__FILE__), 'layout/*')].map {|f| require f }

module Qor
  module Layout
    class << self
      attr_accessor :paperclip_config
    end
  end
end
