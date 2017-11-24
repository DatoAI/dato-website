class InvitationsController < ApplicationController
  before_action :authenticate_user!, :set_invitation, only: [:show, :edit, :update, :destroy]
  before_action :set_collections, only: [:new, :edit, :create, :update]

  # GET /invitations
  def index
    @q = Invitation.ransack(params[:q]) 
    @invitations = policy_scope(@q.result)
    authorize(@invitations)
  end

  # GET /invitations/1
  def show
    authorize(@invitation)
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
    @invitation.competition = Competition.new
    authorize(@invitation)
  end

  # GET /invitations/1/edit
  def edit
    authorize(@invitation)
  end

  # POST /invitations
  def create
    @invitation = Invitation.new(invitation_params)
    authorize(@invitation)
    @invitation.user = current_user
    @invitation.guests.each {|i| i.secret_hash = SecureRandom.hex(16) }
    if @invitation.save
      send_email(@invitation)
      redirect_to @invitation, notice: 'Convite criado com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /invitations/1
  def update
    authorize(@invitation)
    @invitation.set_guests(invitation_params[:user_ids])
    if @invitation.update(invitation_params) 
      send_email(@invitation)
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

    def send_email(invitation)
      invitation.guests.each {|g| InvitationMailer.welcome_email(g).deliver_now}
    end

    def set_collections
      @users = User.where.not(id: current_user)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def invitation_params
      params.require(:invitation).permit(:name, :description, :competition_id, :user_id, user_ids: [])
    end
end
