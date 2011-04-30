require 'sys/proctable'

class Ps
  include Sys

  MAX_PID = File.read('/proc/sys/kernel/pid_max').to_i
  PAGE_SIZE = `getconf PAGE_SIZE`.to_i

  def self.all(opts = {})
    list = ProcTable.ps.map do |pt|
      proc_table_to_hash(pt)
    end

    if filter = opts[:filter]
      list.delete_if do |process|
        process[:comm] != filter
      end
    end

    if order = opts[:order]
      list.sort_by! do |process|
        process[order.to_sym]
      end
      list.reverse!
    end

    list
  end

  def self.details(pid)
    return nil if pid > MAX_PID

    if proc_table = ProcTable.ps(pid)
      proc_table_to_hash(proc_table, true)
    end
  end

  private

  def self.proc_table_to_hash(proc_table, full=false)
    info = Hash[*proc_table.members.zip(proc_table.values).flatten]

    unless full
      info.keep_if do |key, value|
        [:pid, :rss, :vsize, :comm, :cmdline, :state].include?(key)
      end
    end

    if rss = info[:rss]
      info[:rss_bytes] = rss * PAGE_SIZE
    end

    info
  end
end
