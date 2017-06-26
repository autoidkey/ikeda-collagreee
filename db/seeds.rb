# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


8.times do |i|
	6.times do |t|
		num = 10* i + t
		array = [t+1,i+1]
		flag = true
		if ![[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7]].include?(array)
  			User.create(:name => "user#{num}",realname: "user#{num}", email: "test#{num}@test.co.jp", password: "123456", role: 2, row: i+1, col: t+1)
  		end
	end
end

3.times do |i|
	num = i + 1
	User.create(:name => "admin#{num}",realname: "admin#{num}", email: "admin#{num}@admin.co.jp", password: "123456", role: 0)
end