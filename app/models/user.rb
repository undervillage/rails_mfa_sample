class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :recoverable, :validatable, :registerable

  before_create :ensure_otp_secret

  # 渡されたTOTPコードを検証する（少しだけ時間のズレを許容）
  def otp_verified?(code, at: Time.current, drift: 1)
    # 空の入力やシークレット未設定時は即座に否認
    return false if otp_secret.blank? || code.blank?

    # 時間揺れを少しだけ許容しつつTOTPを検証
    totp.verify(code, at: at, drift_behind: drift, drift_ahead: drift)
  end

  # Authenticatorアプリに読み込ませるためのプロビジョニングURIを生成
  def provisioning_uri
    # Authenticator登録用URIを発行
    totp.provisioning_uri(email)
  end

  # 発行者・シークレットを一元管理するTOTPオブジェクトを返す
  def totp
    issuer = Rails.configuration.x.otp_issuer || "MfaSample"
    # Centralized TOTP builder so issuer/secret are consistent across app
    @totp ||= ROTP::TOTP.new(otp_secret, issuer: issuer)
  end

  private

  # 新規作成前にTOTPシークレットと有効化日時を自動設定
  def ensure_otp_secret
    self.otp_secret ||= ROTP::Base32.random_base32
    self.otp_enabled_at ||= Time.current
  end
end
