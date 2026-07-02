namespace :irrigation do
  desc "当日降雨量カウンターをリセットする（JST 03:00 whenever cron から起動）"
  task daily_reset: :environment do
    DailyResetter.new.execute_reset
  end
end
