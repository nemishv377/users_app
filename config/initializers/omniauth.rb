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

  provider :github,
           ENV['GITHUB_KEY'],
           ENV['GITHUB_SECRET'],
           scope: 'user,repo,gist'

  provider :linkedin, ENV['LINKEDIN_CLIENT_ID'], ENV['LINKEDIN_CLIENT_SECRET'],
           scope: 'openid profile email',
           client_options: {
             token_url: 'https://www.linkedin.com/oauth/v2/accessToken',
             auth_scheme: :request_body
           }

  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
           scope: 'email, public_profile',
           info_fields: 'email, first_name, last_name, name, gender'
end
