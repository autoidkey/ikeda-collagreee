class EntryPointJob
  def execute
    Entry.all.each do |entry|
      entry.scored(entry.point)
    end
  end
end
