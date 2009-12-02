if ENV["MODE"]
  Ramaze.options.mode = ENV["MODE"].to_sym 
  puts "using #{Ramaze.options.mode.inspect} mode supplied by environment"
end

Ramaze.middleware :spec do |mode|
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
end

Ramaze.middleware :dev do |mode|
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
  mode.use Rack::NoCache
  mode.use Ramaze::Reloader
  mode.run Ramaze::AppMap
end

Ramaze.middleware :live do |mode|
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
end

