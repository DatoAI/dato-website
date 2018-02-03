require 'csv'

class DashboardController < ApplicationController
  before_action :authenticate_user!, only: [:home, :list_users]

  # GET /dashboard/home
  def home
    @q = User.ransack(params[:q]) 
    authorize(current_user)
    @search_filter = false
  end

  # GET /dashboard/list_users
  def list_users
    authorize(current_user)
    @q = User.ransack(params[:q]) 
    @users = @q.result
    @search_filter = true
    render :home  
  end

  def export_users_to_csv
    respond_to do |format|
      format.html
      format.csv { send_data users_to_csv(User.all), filename: "users-#{Date.today}.csv" }
    end        
  end

  def users_to_csv (users)
    attributes_pt = %w{id nome email data_cadastro}
    attributes = %w{id name email created_at}

    CSV.generate(headers: true) do |csv|
      csv << attributes_pt

      users.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

end
