class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy, :index, :vote]
	
	def index
    #raise params.inspect
    #get all the posts order by votes
    @microposts_tmp = Micropost.order("votes DESC")
    @microposts = []
    count = 0
    #get the current season's round number
    season = Season.find_by_current(true)

    #get all the posts
    @microposts_tmp.each do |micropost|

      if count < season.round
        @microposts[count] = micropost
        count = count + 1
      else
        #Get all the post that has the same vote qty than the last one.
        if @microposts[count - 1].votes  == micropost.votes
          @microposts[count] = micropost
          count = count + 1
        else
          break
        end
      end
    end
    
    #Un-sort the posts
    @microposts.shuffle!
 

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
    
    #find the microposts in the databse to add their current votes
    params[:microposts].each do |key, value|
      micropost = Micropost.find(key)
      params[:microposts][key]["votes"] = (params[:microposts][key]["votes"].to_i  + micropost.votes).to_s      
    end

    #update microposts
    @microposts = Micropost.update(params[:microposts].keys, params[:microposts].values).reject { |p| p.errors.empty? }
    if @microposts.empty?
      flash[:notice] = "Thank you for your vote"
      #raise
      #Set user to prevent her from voting until admin resets it
      current_user.vote = true
      current_user.save(:validate => false)
      #each save of user resets the remember token so users needs to be signed again.
      sign_in current_user
     

      redirect_to microposts_url
    else
      render :action => "index"
    end

  end

  def set_round
    #raise params.inspect
    season = Season.find_by_current(true)

    #change round if a new number is submited.
    if !params[:round].blank?
      season.round = params[:round]
    else
      season.round = 10
    end
    season.save!

    #Reset votes if checkbox is selected
    if params.has_key?(:reset_vote) 
      User.update_all( {:vote => false})   
    end
    redirect_to microposts_url
    #end
  end
end