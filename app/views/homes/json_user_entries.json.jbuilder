json.array! @entry_tree do |entry_tree|
  json.id entry_tree.id
  json.title entry_tree.title
  json.body entry_tree.body
  json.theme_id entry_tree.theme_id
end
