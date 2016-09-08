require 'redis'
if ENV['HEROKU_ENV']
	Redis.current = Redis.new(host: 'ec2-184-73-182-114.compute-1.amazonaws.com', port: 15529)
else
	Redis.current = Redis.new(host: '127.0.0.1', port: 6379)
end
