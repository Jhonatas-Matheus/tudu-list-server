class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  
  before_create :generate_subtask_ids

  field :title, type: String
  field :description, type: String
  field :deadline, type: Date
  field :status, type: Integer
  field :priority, type: Integer
  field :files, type: Array, default: []
  field :subtasks, type: Array, default: []
  field :categories, type: Array, default: []
  field :owner, type: String

  has_and_belongs_to_many :users
  has_many :comments
  accepts_nested_attributes_for :comments
  private

  def generate_subtask_ids
    self.subtasks.each do |subtask|
      subtask['subtask_id'] = UUIDTools::UUID.random_create.to_s
    end
  end
end
