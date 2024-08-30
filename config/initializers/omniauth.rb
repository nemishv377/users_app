Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             #  name: 'google',
             scope: 'email, profile', #-- This will allow us to get the user's email address and profile picture.
             prompt: 'select_account', #-- This will allow the user to select which account they want to login with.
             image_aspect_ratio: 'square', #-- This will make sure that the profile picture is a square.
             image_size: 50 #-- This will make sure that the profile picture is 50x50 pixels.
           }
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'user,repo,gist'
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, ENV['LINKEDIN_CLIENT_ID'], ENV['LINKEDIN_CLIENT_SECRET'],
           scope: 'openid profile email',
           response_type: :code,
           client_options: {
             scheme: 'https',
             authorization_endpoint: '/oauth2/auth',
             token_endpoint: '/oauth2/token',
             userinfo_endpoint: '/userinfo'
           }
end
