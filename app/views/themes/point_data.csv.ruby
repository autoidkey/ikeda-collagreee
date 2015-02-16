require 'csv' # initializersとかに書いたほうがいいかも

csv_data = CSV.generate do |csv|
  cols = {
    'ID'     => ->(u){ u.id },
    '時間'   => ->(u){ u.created_at },
    'ポイント' => ->(u){ u.point },
    '獲得ユーザー' => ->(u){ u.user.name },
    '獲得ユーザーId' => ->(u){ u.user.id },
    '投稿ID' => ->(u){ u.entry.id },
    'ポイント種類' => ->(u){ u.action },
    'いいねID' => ->(u){ u.like_id },
  }

  # header
  csv << cols.keys

  # body
  @point_histories.each do |point_history|
    csv << cols.map{|k, col| col.call(point_history) }
  end
end

#sjis_safe(csv_data).encode(Encoding::SJIS)
