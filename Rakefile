desc 'start rethinkdb'
task :rethink do
  system <<-BASH
  safe_start_rethink() {
    if ps ax | grep -q [r]ethink ; then
      rethinkdb &> tmp/rethinkdb.log &
    fi
  }

  ps_rethink() {
    ps ax \
      | grep rethink \
      | grep -Ev "(grep|rake)"
  }

  safe_start_rethink
  ps_rethink
  BASH
end

desc 'start webserver with shotgun'
task :shotgun => [ :rethink ] do
  exec 'bundle exec shotgun -Ilib -p 4567 -o 0.0.0.0'
end
