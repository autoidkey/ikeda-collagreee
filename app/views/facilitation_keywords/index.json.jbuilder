json.array!(@facilitation_keywords) do |facilitation_keyword|
  json.extract! facilitation_keyword, :id, :theme_id, :word, :score
  json.url facilitation_keyword_url(facilitation_keyword, format: :json)
end
