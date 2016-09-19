json.array!(@core_times) do |core_time|
  json.extract! core_time, :id, :theme_id, :start_at, :end_at, :notice
  json.url core_time_url(core_time, format: :json)
end
