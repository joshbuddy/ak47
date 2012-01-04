require 'guard'
require 'shell_tools'
require "ak47/version"

module Ak47
  class << self
    def run(*argv)
      command = ShellTools.escape(argv)
      @listener_exited = true
      raise "No command was given" if command.empty?
      kill_subprocess = proc do
        begin
          Process.kill("INT", @pid) if @pid
        rescue Errno::ESRCH
        end
      end
      trap("INT", &kill_subprocess)
      at_exit(&kill_subprocess)
      listener = Guard::Listener.select_and_init(:watchdir => Dir.pwd, :watch_all_modifications => true)
      listener.on_change {
        @listener_exited = true
        Process.kill("INT", @pid) if @pid
      }
      listener_thread = Thread.new { listener.start }
      listener_thread.abort_on_exception = true
      while @listener_exited do
        @listener_exited = false
        @pid = fork do
          exec(command.to_s)
        end
        Process.waitpid(@pid)
      end
    end
  end
end