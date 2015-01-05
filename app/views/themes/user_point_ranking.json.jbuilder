json.set! :ranking do
  json.array! @ranking do |user|
    json.id user.id
    json.name user.name
    json.rank user.rank(@theme)
    json.point user.rank_point(@theme)
  end
end