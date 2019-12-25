class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  
$actualOrder = "asc"
  
  # GET /issues
  # GET /issues.json
  def index
    @issues = Issue.all
    if params.has_key?(:typeOptions)
      @issues = Issue.where(issueType: params[:typeOptions])
    end
      
      
    if params.has_key?(:priorityOptions)
      @issues = Issue.where(priority: params[:priorityOptions])
    end
    
    
    if params.has_key?(:statusOptions)
      if params[:statusOptions] == "New&open"
        @issues = Issue.where(status: ["Open", "New"])
      else
        @issues = Issue.where(status: params[:statusOptions])
      end
    end
    
    if params.has_key?(:idActualUser)
      userName = User.find(params[:idActualUser]).name
      @issues = Issue.where(assignee: userName)
    end
    
    if params.has_key?(:watcher)
      if User.exists?(id: params[:watcher])
        @issues = Issue.joins(:watchers).where(watchers: {user_id: params[:watcher]})
      end
    end
    
    
    if params.has_key?(:assignee)
      if !params[:assignee].nil?
        @issues = Issue.where(assignee: params[:assignee])
      end
    end
    
    
    if params.has_key?(:OrderBy)
      if params[:OrderBy] == "title"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:title)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(title: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "type"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:issueType)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(issueType: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "priority"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:priority)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(priority: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "status"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:status)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(status: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "votes"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:num_votes)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(num_votes: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "assignee"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:assignee)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(assignee: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "created"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:created_at)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(created_at: :desc)
          $actualOrder = "asc";
        end
      end
      
      if params[:OrderBy] == "updated"
        if $actualOrder == "asc"
          @issues = Issue.reorder(:updated_at)
          $actualOrder = "desc";
        else 
          @issues = Issue.reorder(updated_at: :desc)
          $actualOrder = "asc";
        end
      end
      
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    
    @comments = Comment.where(issue_id: @issue).order("created_at DESC")
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end
  
  
  
  # POST /issues/issue_id/vote
  def vote
    respond_to do |format|
      @issue_voted = Issue.find(params[:id])
      if !Vote.exists?(:issue_id => @issue_voted.id, :user_id => current_user.id)
        @vote = Vote.new
        @vote.user_id = current_user.id
        @vote.issue_id = @issue_voted.id
        @vote.save
        @issue_voted.increment!("num_votes")
      else
        @vote = Vote.where(issue_id: params[:id], user_id: current_user.id).take
        @vote.destroy
        @issue_voted.decrement!("num_votes")
      end
      format.html {redirect_to @issue_voted}
      format.json {render json: @issue_voted, status: :ok}
    end
  end
  
  # POST /issues/issue_id/watch
  def watch
    respond_to do |format|
      @issue_watched = Issue.find(params[:id])
      if !Watcher.exists?(:issue_id => @issue_watched.id, :user_id => current_user.id)
        @watcher = Watcher.new
        @watcher.user_id = current_user.id
        @watcher.issue_id = @issue_watched.id
        @watcher.save
      else
        @watcher = Watcher.where(issue_id: params[:id], user_id: current_user.id).take
        @watcher.destroy
      end
      if params[:currentView] == "ind"
        format.html {redirect_to issues_url}
      else
        format.html {redirect_to @issue_watched}
      end
      format.json {render json: @issue_watched, status: :ok}
    end
  end
  
  # PUT /issues/attach_id/delete_attachment
  def delete_attachment
    #@fichero = ActiveStorage::Blob.find_signed(params[:id])
    #@fichero.purge
    @issue_actual = Issue.find(params[:id])
    @issue_actual.attachments.purge
    redirect_to @issue_actual
  end
  
  # DELETE /issues/sign_out
  def sign_out
    reset_session
    session.clear
    redirect_to issues_url
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @issue.num_votes = 0
    @issue.user_id = current_user.id
    @issue.status = "New"

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    @priority = @issue.priority
    @type = @issue.issueType
    @title = @issue.title
    @desc = @issue.description
    @att = @issue.attachments
    @status = @issue.status

    respond_to do |format|
      if @issue.update(issue_params)
        if @issue.priority != @priority || @issue.title != @title || @issue.issueType != @type || @issue.description != @desc || @att.length != @issue.attachments.length
          @body = ''
          
          if @issue.priority != @priority
            @body = @body + "\n" + "marked as " + @issue.priority
          end
          if @issue.title != @title
            @body = @body + "\n" + "changed title to " + @issue.title
          end
          if @issue.issueType != @type
            @body = @body + "\n" + 'marked as ' + @issue.issueType
          end
          if @issue.description != @desc
            @body = @body + "\n" + 'edited description'
          end
          
          if @att.length != @issue.attachments.length
            
            if @att.length < @issue.attachments.length
              @esta = false
              @diff = @issue.attachments.length - @att.length
              (0...@issue.attachments.count).each do |attach|
                @name = @issue.attachments[attach].filename
                (0...@att.count).each do |at|
                  if @att[at].filename == @name
                    @esta = true
                    
                  end
                end
                if not @esta 
                  @body = @body + "\n" + 'attached file ' + @name
                else
                  @esta = false
                end
              end
            end
            
          end
              
          @comment = set_issue.comments.build(body: @body)
          @comment.user = current_user
          @comment.system = true
          @comment.save
        end
        
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update_status
    respond_to do |format|
      @issue_to_update = Issue.find(params[:id])
      @status = @issue_to_update.status
      @issue_to_update.update_attribute("status", params[:status])
      if @status != @issue_to_update.status
        @comment = @issue_to_update.comments.build(body: 'marked as ' + @issue_to_update.status)
        @comment.user = current_user
        @comment.system = true
        @comment.save
      end
      format.html { redirect_to @issue_to_update }
      format.json { render json: @issue_to_update, status: :ok }
    end
  end
    
  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url}
      format.json { head :no_content }
    end
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:title, :assignee, :issueType, :priority, :user_id, :description,  attachments: [])
    end
end
