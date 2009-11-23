if Ramaze.options[:mode] == :live
  Thread.new do
    FIVE_MINUTES = 5 * 60 
    THREAD_DB_CONFIG = YAML.load(File.read(File.join(__DIR__, '..', 'database.yml')))
    DB = Sequel.connect(THREAD_DB_CONFIG[Ramaze.options[:mode].to_s])
    loop do
      DB[:tickets].filter(:username => nil).filter(:created_at < Time.now - FIVE_MINUTES).delete
      DB[:tickets].filter(~:username => nil).filter(:created_at < Time.now - 30.days).sql
      sleep FIVE_MINUTES
    end
  end
end