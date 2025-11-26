module Users
  class RegistrationsController < Devise::RegistrationsController
    # 署名中ユーザーをセッションから拾い、OTP確認用に保持
    before_action :load_pending_user_for_otp, only: %i[otp_setup verify_otp]

    # サインアップ後はOTP登録フローへ（自動ログインしない）
    def create
      build_resource(sign_up_params)

      if resource.save
        session[:pending_user_id] = resource.id
        redirect_to otp_setup_path
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource, status: :unprocessable_entity
      end
    end

    # OTPセットアップ画面: QRを表示し、次のverifyで二度コードを入力させる
    def otp_setup
      ensure_pending_user!
      @qr_svg = qrcode_svg(@pending_user.provisioning_uri)
    end

    # 連続する2つのOTPコードを検証し、成功したらログイン完了
    def verify_otp
      ensure_pending_user!

      if otp_pair_valid?(@pending_user, params[:otp_code_1], params[:otp_code_2])
        session.delete(:pending_user_id)
        sign_in(@pending_user)
        flash[:notice] = "登録が完了しました。"
        redirect_to dashboard_path
      else
        flash.now[:alert] = "ワンタイムコードが正しくありません。再度お試しください。"
        @qr_svg = qrcode_svg(@pending_user.provisioning_uri)
        render :otp_setup, status: :unprocessable_entity
      end
    end

    protected

    # DeviseのデフォルトリダイレクトをOTPセットアップに差し替え
    def after_sign_up_path_for(_resource)
      otp_setup_path
    end

    private

    def load_pending_user_for_otp
      # OTP確認中のユーザーをセッションから復元
      @pending_user = User.find_by(id: session[:pending_user_id])
    end

    def ensure_pending_user!
      redirect_to new_user_registration_path, alert: "最初からやり直してください。" unless @pending_user
    end

    def otp_valid?(user, code)
      user.otp_verified?(code)
    end

    # Require the second code to be from the next time step (forces waiting for the next TOTP)
    def otp_pair_valid?(user, code1, code2)
      return false if code1.blank? || code2.blank?

      totp = user.totp
      now = Time.current
      first_ok = user.otp_verified?(code1, at: now, drift: 1)
      next_window_time = now + totp.interval
      second_ok = user.otp_verified?(code2, at: next_window_time, drift: 1)

      first_ok && second_ok
    end

    def qrcode_svg(uri)
      # QRコードSVGを生成してOTPセットアップ画面で埋め込む
      qrcode = RQRCode::QRCode.new(uri)
      qrcode.as_svg(
        offset: 0,
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 6,
        standalone: true
      ).html_safe
    end
  end
end
