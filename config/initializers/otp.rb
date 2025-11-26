# OTP issuer used in provisioning URIs (can be overridden via ENV)
Rails.configuration.x.otp_issuer = ENV.fetch("OTP_ISSUER", "MfaSample")
