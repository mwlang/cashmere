# Monkey patch Flash to not rotate for two requests
module Innate
  class Session
    class Flash
      def rotate!
        old = session.delete(:FLASH)
      end
    end
  end
end
