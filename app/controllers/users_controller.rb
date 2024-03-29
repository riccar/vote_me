class UsersController < ApplicationController

	before_filter :signed_in_user, only: [:index, :edit, :update, :hall_of_fame]
	before_filter :correct_user,   only: [:edit, :update]
	before_filter :admin_user,     only: :destroy

	#By default show renders views/users/show.html.erb
	def show
    @user = User.find(params[:id])
    @micropost = current_user.microposts.build
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  #By default new renders views/users/new.html.erb
  def new
    #redirect_to(root_path) unless !signed_in?
    
    @user = User.new
    
  end

	#By default index renders views/users/index.html.erb
 	def index
 		#Get all the users using the paginate gem predef. function
 		@users = User.paginate(page: params[:page], per_page: 30)
 		
 		#Normal call to all users
    #@users = User.all
  end

	def create
	  @user = User.new(params[:user])
	  if @user.save
	  	sign_in @user
	  	flash[:success] = "Welcome participant"
	    redirect_to @user
	  else
	    render 'new'
	  end
	end

	#By default edit renders views/users/edit.html.erb
	def edit
		#below line is no longer needed because before_filter correct_user
		#is being executed for this def
		#@user = User.find(params[:id])
	end

	def update
		#below line is no longer needed because before_filter correct_user
		#is being executed for this def
    #@user = User.find(params[:id])
    if @user.update_attributes(params[:user])
    	flash[:success] = "Profile updated"
    	#User needs to be signed in again because the remember token
    	#is reset after the update.
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def hall_of_Fame
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
