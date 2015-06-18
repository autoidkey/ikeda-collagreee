json.array! @point_history do |point_history|
  json.id point_history.id
  json.point point_history.point
  json.created_at point_history.created_at.to_s(:datetime)
  json.date point_history.created_at.to_s(:date)
end
