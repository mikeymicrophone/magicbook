class Mage < ApplicationRecord
  MAGIC_LINK_LIFETIME = 15.minutes
  MAGIC_LINK_RESEND_INTERVAL = 1.minute

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :trackable, :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :purchases, dependent: :nullify
  has_many :purchased_books, through: :purchases
  has_many :owned_books, through: :purchases, source: :books
  has_many :lists, dependent: :nullify
  has_many :taggings, dependent: :nullify
  has_many :identifiers, dependent: :nullify
  has_many :passkeys, dependent: :destroy
  has_many :received_invitations, class_name: 'Invitation', dependent: :destroy
  has_many :sent_invitations, class_name: 'Invitation', foreign_key: :inviter_id, dependent: :destroy
  has_many :gifted_purchases, through: :received_invitations, source: :purchase
  has_many :gifted_books, through: :gifted_purchases, source: :books

  def self.create_access_account!(email)
    mage = find_or_initialize_by(email: email.to_s.strip.downcase)
    return mage if mage.persisted?

    password = SecureRandom.alphanumeric(32)
    mage.password = password
    mage.password_confirmation = password
    mage.must_set_password = true
    mage.save!
    mage
  end

  def self.google_oauth_configured?
    ENV['GOOGLE_OAUTH_CLIENT_ID'].present? && ENV['GOOGLE_OAUTH_CLIENT_SECRET'].present?
  end

  def self.from_google_oauth!(auth)
    email = auth.info.email.to_s.strip.downcase
    verified_email = auth.info.email_verified || auth.extra&.raw_info&.email_verified
    verified = ActiveModel::Type::Boolean.new.cast(verified_email)
    raise ArgumentError, 'Google did not provide a verified email address.' if email.blank? || !verified

    identifier = Identifier.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    mage = identifier.mage || find_or_initialize_by(email: email)

    if mage.new_record?
      password = SecureRandom.alphanumeric(32)
      mage.assign_attributes(
        password: password,
        password_confirmation: password,
        confirmed_at: Time.current,
        first_name: auth.info.first_name.presence,
        last_name: auth.info.last_name.presence
      )
      mage.save!
    end

    identifier.update!(mage: mage, email: email)
    mage
  end

  def issue_magic_link!
    return if magic_link_sent_at&.after?(MAGIC_LINK_RESEND_INTERVAL.ago)

    token = SecureRandom.urlsafe_base64(32)
    update!(magic_link_token_digest: Digest::SHA256.hexdigest(token), magic_link_sent_at: Time.current)
    token
  end

  def self.consume_magic_link(token)
    return if token.blank?

    digest = Digest::SHA256.hexdigest(token)
    mage = find_by(magic_link_token_digest: digest)
    return unless mage

    updates = { magic_link_token_digest: nil, magic_link_sent_at: nil }
    updates[:confirmed_at] = Time.current unless mage.confirmed?
    consumed = where(id: mage.id, magic_link_token_digest: digest)
      .where('magic_link_sent_at > ?', MAGIC_LINK_LIFETIME.ago)
      .update_all(updates)
    return unless consumed == 1

    mage.reload
  end

  def ensure_webauthn_user_handle!
    return webauthn_user_handle if webauthn_user_handle.present?

    update!(webauthn_user_handle: WebAuthn.generate_user_id)
    webauthn_user_handle
  end

  def accessible_books
    Book.where(id: owned_books.select(:id)).or(Book.where(id: gifted_books.select(:id))).distinct
  end

  def ensure_authentication_token
    return authentication_token if authentication_token.present?

    update!(
      authentication_token: SecureRandom.urlsafe_base64(32),
      authentication_token_created_at: Time.current
    )
    authentication_token
  end

  def needs_access_technique?
    must_set_password? || encrypted_password.blank?
  end
end
