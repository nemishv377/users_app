json.pagination do
  json.extract! @pagy, :count, :limit, :page, :prev, :next, :pages
end
json.users do
  json.array! @users, partial: 'user', as: :user
end
