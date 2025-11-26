class HomeController < ApplicationController
  # 公開トップページ
  def index; end

  # ログイン必須の簡易ダッシュボード
  def dashboard
    authenticate_user!
  end
end
