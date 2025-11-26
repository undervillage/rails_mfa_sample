class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  # 全メールに共通する設定をまとめるベースクラス
end
