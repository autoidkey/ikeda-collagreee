json.array!(@facilitation_infomations) do |facilitation_infomation|
  json.extract! facilitation_infomation, :id, :body, :theme_id
  json.url facilitation_infomation_url(facilitation_infomation, format: :json)
end
