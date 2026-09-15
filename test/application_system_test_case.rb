require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1200, 900 ]

  def sign_in_as(user)
    visit root_path
    page.driver.browser.manage.add_cookie(name: "user_id", value: signed_cookie_for(user), path: "/")
  end

  private
    # The signed cookie a real sign-in would set, minted the way the app mints it.
    def signed_cookie_for(user)
      jar = ActionDispatch::Cookies::CookieJar.build(ActionDispatch::Request.new(Rails.application.env_config.merge("HTTP_HOST" => "127.0.0.1")), {})
      jar.signed[:user_id] = user.id
      jar[:user_id]
    end
end
