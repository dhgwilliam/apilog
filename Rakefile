desc "start redis-server and open cli"
task :redis do
  system 'redis-server &'
  sleep 2
  exec 'redis-cli'
end

desc 'start webserver with shotgun'
task :shotgun do
  exec 'shotgun -s thin apilog.rb -p 4567'
end
