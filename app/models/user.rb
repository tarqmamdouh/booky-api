# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :bookings, dependent: :destroy

  before_save :use_or_create_name

  # Creates random name for user if it was null
  def use_or_create_name
    self.name = Faker::Name.name if name.nil?
  end
end
