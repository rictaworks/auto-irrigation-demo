# whenever gem によるcronスケジュール定義。
# `whenever --update-crontab` でOSのcrontabに反映する（本番はRailwayのCron機能等に置き換え可）。
#
# 表記はJSTを使用する（workflow.md）ため、実行環境のタイムゾーンに関わらず
# JST 03:00 に実行されるよう明示的にTZを指定する。
env :TZ, "Asia/Tokyo"

set :output, "log/cron.log"

every 1.day, at: "3:00 am" do
  rake "irrigation:daily_reset"
end
