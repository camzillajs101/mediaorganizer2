class Image < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true

  acts_as_taggable_on :tags
end
