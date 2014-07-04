class AnalysesController < ApplicationController
load_and_authorize_resource
	
  def index
		@analyses = Analysis.order("code").paginate(:page => params[:page], :per_page => @per_page)
		@columns = ["code", "name"]
		@index = @analyses
		@analysis = Analysis.new
		@span = 5
		@is_table = true
	end

	def create	
		@analysis = Analysis.new(params[:analysis])
		if @analysis.save
			flash[:success] = "Analysis added"
			redirect_to analyses_path
		else
			render :new
		end		
	end

  def edit
		@is_edit_form = true		
	end
	
	def update
		@is_edit_form = true		
		if @analysis.update_attributes(params[:analysis])
			flash[:success] = 'Analysis updated'
			redirect_to analyses_path
		else
			render :edit
		end
	end

	def destroy
		if Analysis.find(params[:id]).destroy		
			flash[:success] = 'Analysis deleted'
			redirect_to analyses_path
		end
	end

		######end of CRUD#######

	def bulk_delete
		Analysis.destroy(params[:analyses])
		redirect_to analyses_path
	end

	
	def instructions
		@analysis = Analysis.find(params[:id])
	end

end
