# frozen_string_literal: true

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Locker

  field :locker_locking_name, type: String
  field :locker_locked_at, type: Time

  locker locked_at_field: :locker_locking_name,
         locked_at_field: :locker_locked_at

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''
  field :first_name,         type: String
  field :last_name,          type: String

  ## Recoverable
  field :reset_password_token,        type: String
  field :reset_password_sent_at,      type: Time
  field :reset_password_redirect_url, type: String
  field :allow_password_change,       type: Boolean, default: false

  ## Rememberable
  field :remember_created_at, type: Time

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  ## Required
  field :provider, type: String
  field :uid,      type: String, default: ''

  ## Tokens
  field :tokens, type: Hash, default: {}

  ## Firebase
  field :firebaseId, type: String

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  index({ email: 1 }, { name: 'email_index', unique: true, background: true })
  index({ reset_password_token: 1 }, { name: 'reset_password_token_index', unique: true, sparse: true, background: true })
  index({ confirmation_token: 1 }, { name: 'confirmation_token_index', unique: true, sparse: true, background: true })
  index({ uid: 1, provider: 1}, { name: 'uid_provider_index', unique: true, background: true })
  # index({ unlock_token: 1 }, { name: 'unlock_token_index', unique: true, sparse: true, background: true })
  has_and_belongs_to_many :tasks
  has_many :comments
  accepts_nested_attributes_for :comments
end
