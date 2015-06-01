json.array!(@f_keywords) do |f_keyword|
  json.extract! f_keyword, :id, :word, :score
  json.url f_keyword_url(f_keyword, format: :json)
end
