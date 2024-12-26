class PeriodicJobsController < ApplicationController

  layout 'admin'

  before_action :require_admin

  def index
    @periodic_jobs = PeriodicJob.all
  end

  def show
    @periodic_job = PeriodicJob.find(params[:id])
    path_to_file = File.join(Rails.root, @periodic_job.path)
    begin
      @job_content = File.read(path_to_file)
    rescue
      puts "!!! #{path_to_file}"
      @job_content = "!!! Problème lors de la lecture du script."
    end
  end

  def new
    @periodic_job = PeriodicJob.new
  end

  def create
    @job = PeriodicJob.new
    @job.safe_attributes = params[:periodic_job]
    @job.author_id = User.current.id
    if @job.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to periodic_jobs_path
    else
      render :action => 'new'
    end
  end

  def edit
    @periodic_job = PeriodicJob.find(params[:id])
  end

  def update
    @job = PeriodicJob.find(params[:id])
    @job.safe_attributes = params[:periodic_job]
    if @job.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to periodic_jobs_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @job = PeriodicJob.find(params[:id])
    @job.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to periodic_jobs_path
  end
end
