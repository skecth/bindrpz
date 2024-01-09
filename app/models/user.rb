class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable
  
  enum role: [:user, :admin]
  has_many :zones, dependent: :destroy
  validates :username, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, length: { minimum: 6 }, on: :create

end
