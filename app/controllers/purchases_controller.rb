class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy, :claim]

  def index
    @purchases = if current_magician
      current_magician.purchases
    elsif current_scribe
      Purchase.all
    end
  end

  def show
  end

  def new
    @purchase = Purchase.new
  end

  def edit
  end

  def create
    @purchase = Purchase.new
    
    @purchase.email = params[:stripeEmail]
    @purchase.stripe_token = params[:stripeToken]
    @purchase.save

    if @purchase.fulfill
      sign_in @purchase.magician
      # BookMailer.purchased(@purchase.id).deliver
      BookMailersend.purchased(@purchase.id).send # likely put this in a background job
      redirect_to invite_muggles_path(:purchase_id => @purchase.id)
    else
      render :text => "The purchase was not completed."
    end
  end

  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to @purchase, notice: 'Purchase was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase }
      else
        format.html { render :edit }
        format.json { render json: @purchase.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchases_url, notice: 'Purchase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def claim
    if @purchase.can_invite_muggles? && @purchase.token == params[:token]
      session[:muggling] = params[:id]
      @muggling = true
    else
      @muggling = false
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase
      @purchase = Purchase.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_params
      params.fetch(:purchase, {}).permit(:email, :stripe_token)
    end
end
