# Be sure to restart your server when you modify this file.
#
# フロントエンド(Next.js)からのCookie付きクロスオリジンリクエストを許可する。
# 許可オリジンはENV経由で環境ごとに切り替える（コード直書きしない）。

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_ORIGIN", "http://localhost:3000")

    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
