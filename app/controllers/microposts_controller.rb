class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy, :index, :vote, :guess_who_process, :guess_who, :results ]
  before_filter :admin_user,     only: [:set_round]
	
	def index
    #raise params.inspect

    #get all the posts order by votes
    @microposts_tmp = Micropost.order("votes_round1 DESC")
    @microposts = []
    count = 0
    #get the current season's round number
    @season = Season.find_by_current(true)
    
    if @season.curr_round == 1    
      total_round = @microposts_tmp.count
    else
      total_round = @season.total_round2
    end

    #get all the posts
    @microposts_tmp.each do |micropost|

      if count < total_round
        @microposts[count] = micropost
        count = count + 1
      else
        #Get all the post that has the same vote qty than the last one.
        if @microposts[count - 1].votes_round1  == micropost.votes_round1
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

    #check current season to sum up the correct vote field
    @season = Season.find_by_current(true)
    
    if @season.curr_round == 1    
      round = "votes_round1"
    else
      round = "votes_round2"
    end

    #find the microposts in the databse to add their current votes
    params[:microposts].each do |key, value|
      micropost = Micropost.find(key)
      if @season.curr_round == 1    
        params[:microposts][key]["votes_round1"] = (params[:microposts][key]["votes_round1"].to_i  + micropost.votes_round1).to_s
      else
        params[:microposts][key]["votes_round2"] = (params[:microposts][key]["votes_round2"].to_i  + micropost.votes_round2).to_s
      end  
      
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
    #Change round type
    season.curr_round = params[:curr_round]

    #change round if a new number is submited.
    
    if !params[:round].blank?
      if season.curr_round == 1
        season.total_round1 = params[:round]
      else
        season.total_round2 = params[:round]
      end
      
    else
      season.total_round1 = 10
      season.total_round2 = 5
    end
    season.save!

    #Allow users to votes if checkbox is selected
    if params.has_key?(:reset_vote) 
      User.update_all( {:vote => false} )   
    end
    redirect_to microposts_url

  end

  def results

    @winner = Micropost.order("votes_round2 DESC").first

    @finalists = Micropost.order("votes_round2 DESC").limit(4).offset(1)
    
    @microposts = Micropost.paginate(page: params[:page]).order("votes_round2 DESC, votes_round1 DESC")
   
    render "results"
  end

  def guess_who

    
    #if user.guess_who_score is blank print the form and the ranking of users otherwise print just the ranking. 
    #if result variable exist print the result 

    @users = User.order("guess_who_score DESC")

    #Get all microposts and unsorted
    #create a form in the view to include the micropost content and the combo box with al the users

    @microposts = Micropost.all
    @microposts.shuffle!

    #In the view, at the top Get a list of all the users and print a table 
    #of users and percentage of acuracy x/total y%

    #raise guess_res.defined?

    render "guess_who"
  end

  def guess_who_process

    @users = User.order("guess_who_score DESC")

    #receive the POST of the form @ guess_who view and send to guess_who action an array of 
    #post content, author, guess, FAIL/PASS
    @microposts = Micropost.all
    @guess_res = []
    i = 0
    score = 0
    @microposts.each do |micropost|
      @guess_res[i] = {}
     
      @guess_res[i]["content"] = micropost.content
      @guess_res[i]["author"] = micropost.user.name
      @guess_res[i]["guess"] = params[:guess][micropost.id.to_s]["user_id"]

      if params[:guess][micropost.id.to_s]["user_id"] == micropost.user.name
        @guess_res[i]["result"] = "PASS"
        score = score + 1
      else
        @guess_res[i]["result"] = "FAIL"
      end
      i = i + 1
    end
    #raise current_user.inspect
    current_user.guess_who_score = score
    current_user.save!(:validate => false)
    sign_in current_user

   render "guess_who"

  end

  private

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
  
end