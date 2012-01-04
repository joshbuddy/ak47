require 'guard'
require 'shell_tools'
require "ak47/version"

module Ak47
  Reload = Class.new(RuntimeError)

  class << self
    def run(*argv)
      command = ShellTools.escape(argv)
      watch_dir = Dir.pwd
      listener = Guard::Listener.select_and_init(:watchdir => watch_dir, :watch_all_modifications => true)
      listener.on_change {
        Thread.main.raise Reload
      }
      Thread.new { listener.start }

      at_exit { Process.kill("INT", @pid) rescue nil if @pid }

      puts "[Starting ak47 #{VERSION} in #{watch_dir.inspect}]"
      loop do
        begin
          puts "[Running... #{Time.new.to_s}]"
          puts "# #{command}"
          @pid = fork { exec(command) }
          _, status = Process.waitpid2(@pid)
          if status.success?
            puts "[Terminated, waiting for file system change]"
            sleep
          else
            puts "[Terminated abnormally (#{status.inspect}), retrying in 5s]"
            sleep 5
          end
        rescue Reload
          puts "[Reloading... #{Time.new.to_s}]"
        end
      end
    end
  end
end