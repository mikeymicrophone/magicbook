class InvitationsController < ApplicationController
  before_action :require_mage!

  def invite
    @purchase = current_mage.purchases.find(params[:purchase_id])
  end

  def submit
    @purchase = current_mage.purchases.find(params[:purchase_id])
    @invitations = []

    invitation_emails.each do |email|
      invitation = create_invitation(email)
      @invitations << invitation
      BookMailer.gifted(@purchase.id, invitation.id, params[:message]).deliver_later if invitation.persisted?
    end

    if @invitations.all?(&:persisted?)
      redirect_to invite_invitations_path(purchase_id: @purchase), notice: 'Your invitations have been sent.'
    else
      render :invite, status: :unprocessable_entity
    end
  end

  def index
    authorize! :manage, :all
    @invitations = Invitation.recent
  end

  def show
    authorize! :manage, :all
    @invitation = Invitation.find(params[:id])
  end

  private

  def require_mage!
    authenticate_mage!
  end

  def invitation_emails
    (1..4).filter_map { |index| params["email_#{index}"].to_s.strip.presence }
  end

  def create_invitation(email)
    Invitation.transaction do
      recipient = Mage.create_access_account!(email)
      Invitation.create!(purchase: @purchase, mage: recipient, inviter: current_mage)
    end
  rescue ActiveRecord::RecordInvalid => error
    Invitation.new(purchase: @purchase, mage: recipient || Mage.new(email: email), inviter: current_mage).tap do |invitation|
      invitation.errors.add(:base, error.record.errors.full_messages.to_sentence)
    end
  end
end
