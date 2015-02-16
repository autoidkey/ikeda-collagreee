require 'csv' # initializersとかに書いたほうがいいかも

csv_data = CSV.generate do |csv|
  cols = {
    'ID'     => ->(u){ u.id },
    '投稿時間'   => ->(u){ u.created_at },
    'タイトル'   => ->(u){ u.title },
    '本文'   => ->(u){ u.body },
    '親投稿ID' => ->(u){ u.parent_id },
    '賛成反対' => ->(u){ u.np },
    'ファシリテーション' => ->(u){ u.facilitation },
  }

  # header
  csv << cols.keys

  # body
  @entries.each do |entry|
    csv << cols.map{|k, col| col.call(entry) }
  end
end

# sjis_safe(csv_data).encode(Encoding::SJIS)
