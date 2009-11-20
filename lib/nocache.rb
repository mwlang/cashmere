module Rack
  class NoCache
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      headers['Pragma'] = 'no-cache'
      headers['Cache-Control'] = 'no-store'

      # expire a year ago!
      headers['Expires'] = (Time.now - 1.year).rfc2822

      [status, headers, body]
    end
  end
end
