# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'roo'

# 8.times do |i|
# 	6.times do |t|
# 		num = 10* i + t
# 		array = [t+1,i+1]
# 		flag = true
# 		if ![[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7]].include?(array)
#   			User.create(:name => "user#{num}",realname: "user#{num}", email: "test#{num}@test.co.jp", password: "123456", role: 2, row: i+1, col: t+1)
#   		end
# 	end
# end

# ods = Roo::Spreadsheet.open('db/idpass1.xlsx')
# ods.each_with_index do |sheet, i|
#   	name =  sheet[0]
#   	email = sheet[1]
#   	pass = sheet[2]
#     array = [[9,4],[9,5],[10,5],[11,5],[9,6],[10,6],[11,6],[3,4],[3,5],[3,6]]
#   	row = i /11 + 1
#   	col = i % 11 + 1
#   	if col != 4 && col != 8 && row < 7
#       if !array.include?([col,row])
#   		  User.create(:name => name,realname: name, email: email, password: pass, role: 2, row: col, col: row)
#       else
#         User.create(:name => name,realname: name, email: email, password: pass, role: 2)
#       end
#   	else
#       User.create(:name => name,realname: name, email: email, password: pass, role: 2)
#     end
# end

# ods = Roo::Spreadsheet.open('db/idpass1.xlsx')
# ods.each do |sheet|
#   	name =  sheet[0]
#   	email = sheet[1]
#   	pass = sheet[2]
#   	User.create(:name => name,realname: name, email: email, password: pass, role: 2)
# end

3.times do |i|
	num = i + 1
	User.create(:name => "admin#{num}",realname: "admin#{num}", email: "admin#{num}@admin.co.jp", password: "123456", role: 0)
end

# User.create(:name => "Prof. Ping Zhong Tong",realname: "なし", email: "ping@collagree.com", password: "123456", role: 2)
# User.create(:name => "Prof. Shigeo Matsubara",realname: "なし", email: "shigeo@collagree.com", password: "123456", role: 2)
# User.create(:name => "Prof. Matthew Taylor",realname: "なし", email: "matthew@collagree.com", password: "123456", role: 2)
# User.create(:name => "Prof. Takayuki Ito",realname: "なし", email: "takayuki@collagree.com", password: "123456", role: 2)
# User.create(:name => "Prof. Minjie Zhang",realname: "なし", email: "minjie@collagree.com", password: "123456", role: 0)

