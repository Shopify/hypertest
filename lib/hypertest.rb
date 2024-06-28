require 'rb-fsevent'

module Hypertest
  class << self
    # ignore: pattern of directories to ignore events for
    # debounce: number of seconds to drop successive event batches after
    #    initiating a run
    # &block: run your tests!
    def run(ignore: %r{/(?:\.git|tmp)/}, debounce: 0.050, &block)
      info("\033[38;5;196mh\033[38;5;197my\033[38;5;198mp\033[38;5;199me\033[38;5;200mr\033[38;5;201mt\033[38;5;202me\033[38;5;203ms\033[38;5;204mt\033[0;1;34m initialized")
      q = Queue.new
      Thread.new { produce(q, ignore) }
      consume(q, debounce, &block)
    end

    private

    def produce(q, ignore)
      fsevent = FSEvent.new
      fsevent.watch(Dir.pwd, latency: 0.0) do |directories|
        directories.reject! { |f| ignore =~ f }
        unless directories.empty?
          q << Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      end
      fsevent.run
    end

    def consume(q, debounce, &block)
      last_run = 0
      while (ts = q.pop)
        if ts - last_run > debounce
          last_run = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          fork_invoke(&block)
        end
      end
    end

    def fork_invoke(&block)
      t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      pid = fork(&block)
      _, stat = Process.waitpid2(pid)
      t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      print_result(t1, t2, stat)
    end

    def print_result(t1, t2, stat)
      ms = ((t2 - t1) * 1000).round
      if stat.success?
        info("Completed in #{ms}ms")
      else
        err("Failed in #{ms}ms")
      end
    end

    def info(msg)
      STDERR.puts("\x1b[1;34m❖ #{msg}\x1b[0m")
    end

    def err(msg)
      STDERR.puts("\x1b[1;31m❖ #{msg}\x1b[0m")
    end
  end
end
