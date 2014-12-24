json.set! :user_point_graph do
  json.array! @points do |point|
    json.id point.id
    json.sum point.sum.present? ? point.sum : 0
    json.created_at point.created_at.to_s(:datetime)
    json.date point.created_at.to_s(:date)
  end
end