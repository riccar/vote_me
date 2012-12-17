class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy, :index, :vote]
	
	def index
    @microposts_tmp = Micropost.order("votes DESC")
    @microposts = []
    count = 0
    @microposts_tmp.each do |micropost|

      if count < 5
        @microposts[count] = micropost
        count = count + 1
      else
        if @microposts[count - 1].votes  == micropost.votes
          @microposts[count] = micropost
          count = count + 1
        else
          break
        end
      end
      
    
    end
    #@microposts = @microposts_tmp
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
    
    #find all of the microposts to add their current votes
    @microposts_tmp = Micropost.all
    @microposts_tmp.each do |micropost|
      if params[:microposts].include?(micropost.id.to_s)
        #check this
       params[:microposts]["191"]["votes"] = params[:microposts]["191"]["votes"].to_i + 1 #micropost.votes.to_i
      end
    end

    #update microposts
    @microposts = Micropost.update(params[:microposts].keys, params[:microposts].values).reject { |p| p.errors.empty? }
    if @microposts.empty?
      flash[:notice] = "Chinazos updated"
      redirect_to microposts_url
    else
      render :action => "index"
    end

  end
end