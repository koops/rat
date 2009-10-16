class Date # :nodoc:
  def to_system_time
    to_time(new_offset, :local)
  end

  private
  def to_time(dest, method)
    Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min, dest.sec)
  end
end

class Time # :nodoc:
  def round_up_to_nearest_minute
    Time.at(self.to_i + (60 - sec) % 60)
  end
end

module Rat
  # Schedule a new at job.  Time is local time.  Pass :no_mail => true in options to supress email for jobs with output.
  # Pass :round_seconds_up if you never want jobs running early ("at: has a resolution of one minute at best and will round down by default).

  def self.add(command, time, opts = {})
    cmd = command.dup
    cmd << ' 2>&1 > /dev/null' if opts[:no_mail]
    jobtime = opts[:round_seconds_up] ? time.round_up_to_nearest_minute : time

    output = `echo "#{cmd}" | at #{jobtime.strftime('%H:%M')} #{jobtime.strftime('%d.%m.%y')} 2>&1`
    raise RuntimeError, "Rat couldn't schedule job." unless $?.exitstatus == 0
    (output[/job (\d+)/i, 1] || -1).to_i
  end

  # Pass an integer id returned from add or list.
  def self.remove(job)
    `at -r #{job}`
    $?.exitstatus == 0
  end

  # Dumps the entire job, with environment.  Handy for debugging failed jobs.
  def self.show(job)
    `at -c #{job}`
  end

  # Gives all the pending at jobs for the current user.
  # [{:job => int, :time => time}, ...]
  def self.list
    output = `at -l`
    raise RuntimeError, "Rat couldn't list jobs." unless $?.exitstatus == 0

    output.map do |l|
      l =~ /(\d+)\t(.*)/
      {:job => ($1 || -1).to_i, :time => DateTime.parse($2).to_system_time}
    end
  end
end
