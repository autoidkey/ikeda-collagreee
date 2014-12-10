class EntryPointJob
  def execute
    Entry.record_timestamps = false
    Entry.all.each do |entry|
      entry.update(has_point: entry.point)
    end
  end
  Entry.record_timestamps = true
end
