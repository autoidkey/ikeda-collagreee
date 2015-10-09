# encoding: utf-8
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
require 'pathname'

# 環境ごとの設定
#--------------------------------------------------------
config  = {}
config["development"] = {
  :port => 3000,
  :socket => '/home/okumura/rails/new_collagree/tmp/sockets/unicorn_new_collagree.sock',
  :worker_processes => 2,
  :working_directory => Pathname.new(File.dirname(__FILE__) + "/..").realpath
}
config["production"] = {
  :port => 8500,
  :socket => '/home/okumura/rails/new_collagree/tmp/sockets/unicorn_new_collagree.sock',
  :worker_processes => 6,
  :working_directory => "#{ENV['HOME']}/rails/new_collagree"
}
#--------------------------------------------------------
#rails_env = ENV['RAILS_ENV'] || 'production'
rails_env = 'production'
#rails_env = ENV['RAILS_ENV'] || 'development'
worker_processes config[rails_env][:worker_processes]
working_directory config[rails_env][:working_directory]
port=config[rails_env][:port]
socket = config[rails_env][:socket]
listen socket
#, :tcp_nopush => true
#listen port, :tcp_nopush => true
timeout 300
pid "tmp/pids/unicorn.pid"
preload_app false
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # 古いマスタープロセスを停止させる
  begin
    old_pid_file= "tmp/pids/unicorn.pid.oldbin"
    if File.exist?(old_pid_file)
      Process.kill("QUIT", File.read(old_pid_file).to_i)
    end
  rescue Errno::ENOENT, Errno::ESRCH => e
    puts "old master quit failed!: #{e.message}"
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  # 古いマスタープロセスを停止させる
  begin
    old_pid_file= "tmp/pids/unicorn.pid.oldbin"
    if File.exist?(old_pid_file)
      Process.kill("QUIT", File.read(old_pid_file).to_i)
    end
  rescue Errno::ENOENT, Errno::ESRCH => e
    puts "old master quit failed!: #{e.message}"
  end

end