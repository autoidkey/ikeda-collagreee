class Issue < ActiveRecord::Base
  belongs_to :theme
  has_many :entries, through: :tagged_entries
  has_many :tagged_entries

  scope :to_object, ->(ids) { where(id: ids) }

  def self.checked(params)
    params.select { |_, v| v == '1' }.keys
  end

end
