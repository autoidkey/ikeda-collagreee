json.array!(@thread_classes) do |thread_class|
  json.extract! thread_class, :id, :title, :parent_class
  json.url thread_class_url(thread_class, format: :json)
end
