module Rack
  class Localize
    def initialize(app)
      @app = app
    end

    # http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    def rank_locales(locales)
      return if locales.nil?
      
      # pull out the local names and sort by queue ranking
      locales.gsub(' ','').split(',').map do |locale| 
        language, queue = locale.strip.split(';q=') 

        # the language code is all lowercase, so we need up upcase the country to keep I18n happy
        code, country = language.split('-')
        language = country.nil? ? code : "#{code}-#{country.upcase}"
        
        # default queue when not present is "1.0" per HTML protocol docs
        queue ||= 1.0
        [language, queue.to_f]
      end.sort{|a, b| b[1] <=> a[1]}.map{|m| m[0]}
    end
      
    def call(env)
      return if env['rack.locale']
      
      locales = rank_locales(env["HTTP_ACCEPT_LANGUAGE"])
      locales ||= [I18n.default_locale.to_s]
      
      I18n.locale = env['rack.locale'] = locales.first

      status, headers, body = @app.call(env)

      headers['Content-Language'] = env['rack.locale']
      [status, headers, body]
    end
  end
end

module Ramaze
  module Helper
    module Localize
      def translate(*args)
        I18n.translate(*args)
      end
      alias t translate

      def localize(*args)
        I18n.localize(*args)
      end
      alias l localize

      def locale
        request.env['RACK_LOCALE']
      end

    end
  end
end


