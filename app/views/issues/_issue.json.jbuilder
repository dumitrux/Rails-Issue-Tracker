json.extract! issue, :id, :title, :assignee, :issueType, :priority, :user_id, :description, :created_at, :updated_at
json.url issue_url(issue, format: :json)
