# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :validatable
  include DeviseTokenAuth::Concerns::User

  before_save :use_or_create_name

  # Creates random name for user if it was null
  def use_or_create_name
    self.name = Faker::Name.name if name.nil?
  end
end
