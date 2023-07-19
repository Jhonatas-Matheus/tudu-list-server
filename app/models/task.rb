class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :description, type: String
  field :deadline, type: Date
  field :status, type: Integer
  field :owner, type: String

  has_and_belongs_to_many :users
  has_many :comments
  accepts_nested_attributes_for :comments
end
