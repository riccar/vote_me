class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
	
	def index
    @microposts = Micropost.all
    #@micropost = current_user.microposts.build
  end

  def create
    #Rails.logger.info("PARAMS: #{params.inspect}")
    @user = User.find(params[:user_id])
  	@micropost = @user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Chinazo created!"
      redirect_to @user
    else
      @microposts = @user.microposts.paginate(page: params[:page])
      params[:id] = @user.id
      render  'users/show'
    end
  end

  def destroy
  end

  def vote
    @microposts = Micropost.all
    
    render  'microposts/index'
  end
end