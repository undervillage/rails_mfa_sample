require "rotp"

email = "user@example.com"
password = "password123"

user = User.find_or_initialize_by(email: email)
user.password = password
user.password_confirmation = password
user.otp_secret ||= ENV.fetch("MFA_SEED_OTP_SECRET", ROTP::Base32.random_base32)
user.otp_required_for_login = true
user.save!

puts "Seed user created/updated:"
puts "  email: #{email}"
puts "  password: #{password}"
puts "  OTP secret: #{user.otp_secret}"
puts "Authenticatorに上記シークレットを登録し、生成された6桁コードでログインしてください。"

begin
  Pathname.new(Rails.root.join("tmp/seed_user.txt")).write(<<~TXT)
    email: #{email}
    password: #{password}
    otp_secret: #{user.otp_secret}
    provisioning_uri: #{user.provisioning_uri}
  TXT
  puts "tmp/seed_user.txt にシードユーザーの情報を書き出しました。"
rescue StandardError => e
  warn "tmp/seed_user.txt への書き出しに失敗しました: #{e.message}"
end
