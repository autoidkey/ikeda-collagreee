class Issue < ActiveRecord::Base
  belongs_to :theme
  has_many :entries, through: :tagged_entries
  has_many :tagged_entries

  validates :name, presence: true

  scope :to_object, ->(ids) { where(id: ids) }

  def self.checked(params)
    (params || {}).select { |_, v| v == '1' }.keys
  end

  def checked_entry(entry,issues)
    issues.each do |issue|
    	if issue.id == self.id
    		return true
    	end
    end
    return false
  end
end
