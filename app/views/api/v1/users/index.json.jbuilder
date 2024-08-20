json.Pagination do
  json.extract! @pagy, :count, :limit, :page, :prev, :next, :pages
end
json.Users do
  json.array! @users, partial: 'api/v1/users/user', as: :user
end
