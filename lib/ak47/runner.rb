module Ak47
  class Runner
    attr_reader :watch_dirs, :maximum, :interval, :error_time, :command, :interrupt

    def initialize(opts = nil, &blk)
      @watch_dirs = Array(opts && opts[:watch_dirs] || Dir.pwd)
      @maximum    = opts && opts[:maximum]
      @interval   = opts && opts[:interval] || 0.01
      @error_time = opts && opts[:error_time] || 5
      @command    = opts && opts[:command]
      @interrupt  = opts && opts.key?(:interrupt) ? opts[:interrupt] : true
      @blk        = blk
    end

    def start
      listeners = watch_dirs.map {|wd| Guard::Listener.select_and_init(:watchdir => wd, :watch_all_modifications => true) }
      change_detected = false
      running = false
      listeners.each do |l|
        l.on_change { |f|
          if @interrupt
            Thread.main.raise Reload, "File system changed"
          else
            change_detected = true
            Thread.main.raise Reload, "File system changed" unless running
          end
        }
        Thread.new { l.start }
      end

      at_exit { Process.kill("INT", @pid) rescue nil if @pid }

      puts "[Starting ak47 #{VERSION} in #{watch_dirs.join(', ')}]".green
      loop do
        begin
          puts "[Running... #{Time.new.to_s}]".yellow
          puts "# #{command}" if command
          if maximum 
            @thread = Thread.new { sleep maximum; Thread.main.raise Reload, "Cancelled due to maximum time" }
          end
          running = true
          change_detected = false
          begin
            @pid = fork(&@blk)
            _, status = Process.waitpid2(@pid)
          ensure
            running = false
          end
          @thread.kill if @thread
          if status.success?
            if change_detected
              puts "[Change detected while previously running]".green
              change_detected = false
            else
              puts "[Terminated, waiting for file system change]".green
              maximum ? sleep(interval) : sleep
            end
          else
            puts "[Terminated abnormally (#{status.inspect}), retrying in 5s]".red
            sleep error_time
          end
        rescue Reload => e
          sleep interval
          puts "[Reloading (#{e.message}) #{Time.new.to_s}]".yellow
        rescue Interrupt
          puts "[Interrupted, exiting]".yellow
          exit
        end
      end
    end
  end
end