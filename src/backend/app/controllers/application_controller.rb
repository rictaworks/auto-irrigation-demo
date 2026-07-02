class ApplicationController < ActionController::API
  # API modeにはデフォルトで含まれないため、セッションCookie操作のために明示的に追加する。
  include ActionController::Cookies
end
