class Issue < ApplicationRecord
  has_many_attached :attachments
  default_scope { order(created_at: :desc)}
  belongs_to :user

  has_many :comments
  has_many :votes, dependent: :destroy
  has_many :watchers, dependent: :destroy
  
  validates :title, presence: true
  validates :issueType, presence: true
  validates :priority, presence: true
  validates :status, presence: true
  
  def self.status
        ["New", "Open", "On hold", "Resolved", "Duplicate", "Invalid", "Won't fix", "Closed"]
  end
end
