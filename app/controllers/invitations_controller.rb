class InvitationsController < ApplicationController
  before_action :authenticate_user!, :set_invitation, only: [:show, :edit, :update, :destroy]
  
  # GET /invitations
  def index
    @invitations = policy_scope(Invitation.all)
  end

  # GET /invitations/1
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations
  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.user = current_user

    if @invitation.save
      redirect_to @invitation, notice: 'Convite criado com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /invitations/1
  def update
    if @invitation.update(invitation_params)
      redirect_to @invitation, notice: 'Convite atualizado com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /invitations/1
  def destroy
    @invitation.destroy
    redirect_to invitations_url, notice: 'Convite apagado com sucesso.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def invitation_params
      params.require(:invitation).permit(:name, :description, :competition_id, :user_id)
    end
end
