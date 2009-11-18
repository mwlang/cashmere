module Ramaze
  module Helper
    module Localize
      def translate(*args)
        I18n.translate(*args)
      end
      alias xlate translate
      alias xl8 translate

      def localize(*args)
        I18n.localize(*args)
      end

      def locale
        request.env['rack.locale']
      end

    end
  end
end
