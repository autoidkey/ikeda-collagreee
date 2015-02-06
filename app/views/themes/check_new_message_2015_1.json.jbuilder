  json.id @entry.id
  json.theme_id @entry.theme.id
  json.created_at @entry.created_at.to_s(:datetime)
