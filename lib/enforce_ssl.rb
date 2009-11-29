if Ramaze.options.mode == :bogus
  require 'rack/utils'
 
  module Rack
    #
    # EnforceSSL is a Rack middleware app that enforces that users visit
    # specific paths via HTTPS. If a sensitive path is requested over
    # plain-text HTTP, a 307 Redirect will be issued leading to the HTTPS
    # version of the Requested URI.
    #
    # MIT License - Hal Brodigan (postmodern.mod3 at gmail.com)
    #
    class EnforceSSL
 
      include Rack::Utils
 
      #
      # Initializes the SSL enforcement rules.
      #
      # @param [#call] app
      # The app to apply SSL enforcement rules on.
      #
      # @param [Array<String, Regexp>] rules
      # URI paths and patterns to enforce SSL upon.
      #
      # @example
      # use Rack::EnforceSSL, ['/login', /\.xml$/]
      #
      def initialize(app,rules)
        @app = app
 
        patterns = []
        paths = []
 
        rules.each do |pattern|
          if pattern.kind_of?(Regexp)
            patterns << pattern
          else
            paths << pattern
          end
        end
 
        @rules = patterns + paths.sort.reverse
      end
 
      def call(env)
        uri = env['REQUEST_URI']
 
        unless uri[0,6] == 'https:'
          path = env['PATH_INFO']
 
          enforce = @rules.any? do |pattern|
            if pattern.kind_of?(Regexp)
              path =~ pattern
            else
              path[0,pattern.length] == pattern
            end
          end
 
          if enforce
            return [
              307,
              {
                'Content-Type' => 'text/html',
                'Location' => uri.gsub(/^http:/,'https:')
              },
              [%{<html>
  <head>
  <title>SSL Redirect</title>
  </head>
 
  <body>
  <h1>SSL Redirect</h1>
 
  <p>The requested path (#{escape_html(path)}) must be requested via SSL. You are now being redirected to the SSL encrypted path.</p>
  </body>
  </html>}]
            ]
          end
        end
 
        @app.call(env)
      end
 
    end
  end

end # if mode 