class Date
  def to_system_time
    to_time(new_offset, :local)
  end

  private
  def to_time(dest, method)
    Time.send(method, dest.year, dest.month, dest.day, dest.hour, dest.min, dest.sec)
  end
end

module Rat
  def self.add(command, time, opts = {})
    cmd = command.dup
    cmd << ' 2>&1 > /dev/null' if opts[:no_mail]
    output = `echo "#{cmd}" | at -t #{time.strftime('%y%m%d%H%M.%S')} 2>&1`
    raise RuntimeError, "Rat couldn't schedule job." unless $?.exitstatus == 0
    (output[/job (\d+)/i, 1] || -1).to_i
  end

  def self.remove(job)
    `at -r #{job}`
    $?.exitstatus == 0
  end

  def self.show(job)
    `at -c #{job}`
  end

  def self.list
    output = `at -l`
    raise RuntimeError, "Rat couldn't list jobs." unless $?.exitstatus == 0

    output.map do |l|
      l =~ /(\d+)\t(.*)/
      {:job => ($1 || -1).to_i, :time => DateTime.parse($2).to_system_time}
    end
  end
end
