class AnalysesController < ApplicationController
load_and_authorize_resource
	
  def index
		@analyses = Analysis.find(:all).paginate(:page => params[:page], :per_page => 30)
		@index = @analyses
		@analysis = Analysis.new
		@span = 5
		@is_index_table = true
	end
	
	def create
		if params[:commit] != 'Cancel'
			@analysis = Analysis.new(params[:analysis])
			if @analysis.save
				flash[:success] = "analysis added"
			else
				flash[:error] = "analysis could not be added"
#TODO Add more descriptive error messages
			end
		end
		redirect_to analyses_path
	end

  def edit
		@is_edit_form = true		
	end
	
	def update
		if params[:commit] != 'Cancel'
			if @analysis.update_attributes(params[:analysis])
				flash[:success] = 'analysis updated'
			end
		end
		redirect_to analyses_path
	end
	
	def instructions
		@analysis = Analysis.find(params[:id])
	end
end
