module Ak47
  class Runner
    attr_reader :watch_dirs, :command, :maximum, :interval, :error_time

    def initialize(watch_dirs, command, maximum, interval, error_time)
      @watch_dirs, @command, @maximum, @interval, @error_time = watch_dirs, command, maximum, interval, error_time
    end

    def start
      listeners = watch_dirs.map {|wd| Guard::Listener.select_and_init(:watchdir => wd, :watch_all_modifications => true) }
      listeners.each do |l|
        l.on_change { |f| Thread.main.raise Reload, "File system changed" }
        Thread.new { l.start }
      end

      at_exit { Process.kill("INT", @pid) rescue nil if @pid }

      puts "[Starting ak47 #{VERSION} in #{watch_dirs.join(', ')}]"
      loop do
        begin
          puts "[Running... #{Time.new.to_s}]"
          puts "# #{command}"
          if maximum 
            @thread = Thread.new { sleep maximum; Thread.main.raise Reload, "Cancelled due to maximum time" }
          end
          @pid = fork {
            exec(command)
          }
          _, status = Process.waitpid2(@pid)
          @thread.kill if @thread
          if status.success?
            puts "[Terminated, waiting for file system change]"
            maximum ? sleep(interval) : sleep
          else
            puts "[Terminated abnormally (#{status.inspect}), retrying in 5s]"
            sleep error_time
          end
        rescue Reload => e
          sleep interval
          puts "[Reloading (#{e.message}) #{Time.new.to_s}]"
        rescue Interrupt
          puts "[Interrupted, exiting]"
          exit
        end
      end
    end
  end
end