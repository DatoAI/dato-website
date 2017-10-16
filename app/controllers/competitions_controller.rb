class CompetitionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :disable, :enable]
  before_action :set_competition, only: [:show, :edit, :update, :destroy, :disable, :enable]

  # GET /competitions
  def index
    if current_user.nil? || !current_user.admin?
      params[:q] = {visible_eq: 'enabled'}
    end  
    @q = Competition.ransack(params[:q]) 
    @competitions = policy_scope(@q.result)
  end

  # GET /competitions/1
  def show
    authorize(@competition)
  end

  # GET /competitions/new
  def new
    authorize(@competition = Competition.new_with_instructions)
  end

  # GET /competitions/1/edit
  def edit
    authorize(@competition)
  end

  # POST /competitions
  def create
    @competition = Competition.new(competition_params)
    authorize(@competition)
    if @competition.save
      redirect_to @competition, notice: 'Competição criada com sucesso.'
    else
      render :new
    end
  end

  # PATCH/PUT /competitions/1
  def update
    authorize(@competition)
    if @competition.update(competition_params)
      redirect_to @competition, notice: 'Competição atualizada com sucesso.'
    else
      render :edit
    end
  end

  # DELETE /competitions/1
  def destroy
    authorize(@competition)
    @competition.destroy
    redirect_to competitions_url, notice: 'Competição apagada com sucesso.'
  end

  #PATCH/PUT /competitions/1
  def disable
    authorize(@competition)
    if @competition.disable_visible
      redirect_to competitions_url, notice: 'Competição desabilitada com sucesso.'
    else
      render :edit
    end  
  end 
  
  #PATCH/PUT /competitions/1
  def enable
    authorize(@competition)
    if @competition.enable_visible
      redirect_to competitions_url, notice: 'Competição habilitada com sucesso.'
    else
      render :edit
    end  
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_competition
    @competition = Competition.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def competition_params
    params.require(:competition).permit(:name, :max_team_size, :metric, :expected_csv, :deadline, :ilustration, :total_prize, :daily_attempts, instructions_attributes: [:id, :name, :markdown, :_destroy, attachments_files: []])
  end
end
