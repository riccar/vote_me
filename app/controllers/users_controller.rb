class UsersController < ApplicationController

	before_filter :signed_in_user, only: [:index, :edit, :update]
	before_filter :correct_user,   only: [:edit, :update]
	before_filter :admin_user,     only: :destroy

	#By default show calls views/users/show.html.erb
	def show
    @user = User.find(params[:id])
  end
  
  #By default new calls views/users/new.html.erb
  def new
  	@user = User.new
  end

	#By default index calls views/users/index.html.erb
 	def index
 		#Get all the users using the paginate gem predef. function
 		@users = User.paginate(page: params[:page])
 		
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

	#By default edit calls views/users/edit.html.erb
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
  .

  private

    def signed_in_user
    	unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
      #Equivalent to below if it can be writen in one line
      #redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
