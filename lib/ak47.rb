require 'guard'
require 'shell_tools'
require "ak47/version"
require "ak47/runner"

module Ak47
  Reload = Class.new(RuntimeError)

  class << self
    def run(*argv)
      argv_opts, commands = if argv == ['--help'] or argv == ['-help']
        [argv, []]
      elsif divider_index = argv.index('---')
        [argv[0...divider_index], argv[divider_index.succ...argv.size]]
      else
        [[], argv]
      end

      interval, maximum, error_time = 0.01, nil, 5
      optparse = OptionParser.new do |opts|
        opts.banner = "Usage: ak47 [cmd] / ak47 [options] --- [cmd]"

        opts.on( '-i', '--interval [FLOAT]', 'Interval before restarting' ) do |i|
          interval = Float(i)
        end
        opts.on( '-m', '--maximum [FLOAT]', 'Maximum time to wait before restarting' ) do |m|
          maximum = Float(m)
        end
        opts.on( '-e', '--error-time [FLOAT]', 'Maximum time to wait before restarting if there was an abnormal status code' ) do |e|
          error_time = Float(e)
        end
        opts.on( '-h', '--help', 'Display this screen' ) do
          puts opts
          exit
        end
      end
      optparse.parse!(argv_opts)
      watch_dirs = argv_opts
      watch_dirs << Dir.pwd if watch_dirs.empty?
      watch_dirs.map! { |wd| File.expand_path(wd, Dir.pwd) }

      command = ShellTools.escape(commands).strip
      raise "No command supplied" if command.empty?
      Runner.new(watch_dirs, command, maximum, interval, error_time).start
    end
  end
end