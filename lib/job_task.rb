class JobTask
  class << self
    def execute
      execute_job "echo Hellow"
    end

    def cancel(pid)
      command = "ps -p #{pid} -o \"pgid\""
      pgid = system_command(command).lines.to_a.last.lstrip.chomp
      if pgid =~ /[0-9]/
        system_command "kill -TERM -#{pgid}"
        p "canceled!"
      else
        Rails.logger.error 'Process was not found'
      end
    end

    private

    def execute_job(command)
      begin
        fork do
          Process.setsid
          pid = system_command(command).lstrip.chomp
          if pid =~ /[0-9]/
            p pid
          else
            Rails.logger.error 'command has not pid'
          end
        end
      rescue => e
        Rails.logger.error e.message
      end
    end

    def system_command(command)
      `#{command}`
    end
  end
end