module Users
  class SessionsController < Devise::SessionsController
    # パスワード認証後にTOTPも通す独自ログイン処理
    def create
      self.resource = warden.authenticate(auth_options)

      if resource && otp_passed?(resource)
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      else
        flash.now[:alert] = resource.nil? ? I18n.t("devise.failure.invalid", authentication_keys: "email") : "Invalid verification code"
        sign_out(resource) if resource
        self.resource = resource_class.new(sign_in_params)
        render :new, status: :unprocessable_entity
      end
    end

    private

    def otp_passed?(user)
      return true unless user.otp_required_for_login?

      # パスワード認証後にTOTPを検証
      user.otp_verified?(params.dig(:user, :otp_code))
    end
  end
end
