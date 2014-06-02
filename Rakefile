desc 'start rethinkdb'
task :rethink do
  system <<-BASH
  if ps ax | grep -q [r]ethink ; then
    rethinkdb &> tmp/rethinkdb.log &
  fi
  BASH
end

desc 'start webserver with shotgun'
task :shotgun => [ :rethink ] do
  exec 'bundle exec shotgun -Ilib -p 4567 -o 0.0.0.0'
end
