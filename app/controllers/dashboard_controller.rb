class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:home, :list_users]

  # GET /dashboard/home
  def home
    @q = User.ransack(params[:q]) 
    authorize(current_user)
    @search_filter = false
  end

  # GET /dashboard/home
  def list_users
    authorize(current_user)
    @q = User.ransack(params[:q]) 
    @users = @q.result
    @search_filter = true
    render :home  
  end

end
