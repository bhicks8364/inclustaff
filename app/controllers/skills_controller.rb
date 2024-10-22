# == Schema Information
#
# Table name: skills
#
#  id             :integer          not null, primary key
#  name           :string
#  required       :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  skillable_type :string
#  skillable_id   :integer
#

class SkillsController < ApplicationController
  before_action :set_skill, only: [:show, :edit, :update, :destroy]
  layout 'admin_layout'
  # GET /skills
  # GET /skills.json
  def index
    @q = Skill.includes(:skillable).ransack(params[:q])
    @skills = @q.result(distinct: true)
    @employee_skills = @skills.employee.includes(:skillable).order(:name).distinct
    @order_skills = @skills.job_order.includes(:skillable).order(:name).distinct
    # query = params[:q].presence || "*"
    # @skills = Skill.search query, suggest: true
    # Product.search "peantu butta", suggest: true
    
    # @skills = Skill.select(:name).distinct
    # @skills = Skill.all.distinct
    @import = Skill::Import.new
    # gon.skills = @shifts
    # @emp_skills = Skill.employee.includes(:skillable).order(:name)
    skip_authorization
  end
  def import
      @import  = Skill::Import.new(skill_import_params)
      if @import.save
          redirect_to skills_path, notice: "Imported #{@import_count} skills."
      else
          @skills = Skill.all
          render action: :index, notice: "There were errors with your CSV file."
      end
      skip_authorization
        
  end

  # GET /skills/1
  # GET /skills/1.json
  def show
  end

  # GET /skills/new
  def new
    @skill = Skill.new
    skip_authorization
  end

  # GET /skills/1/edit
  def edit
  end

  # POST /skills
  # POST /skills.json
  def create
    @skill = Skill.new(skill_params)
    skip_authorization

    respond_to do |format|
      if @skill.save
        format.html { redirect_to @skill, notice: 'Skill was successfully created.' }
        format.js {}
        format.json { render :show, status: :created, location: @skill }
      else
        format.html { render :new }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end
  def update_all
    Order.all.each do |job_order|
      job_order.set_note_skills
      job_order.save
    end
    WorkHistory.all.each do |work_history|
      work_history.set_listed_skills
      work_history.save
    end
      skip_authorization
        redirect_to skills_path, notice: 'Successfully updated all job order skills'
      
  end
  # PATCH/PUT /skills/1
  # PATCH/PUT /skills/1.json
  def update
    respond_to do |format|
      if @skill.update(skill_params)
        format.html { redirect_to @skill, notice: 'Skill was successfully updated.' }
        format.json { render :show, status: :ok, location: @skill }
      else
        format.html { render :edit }
        format.json { render json: @skill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skills/1
  # DELETE /skills/1.json
  def destroy
    @skill.destroy
    respond_to do |format|
      format.js {}
      format.html { redirect_to :back, notice: 'Skill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def autocomplete
    render json: Skill.search(params[:term], fields: [{name: :text_start}])
    skip_authorization
  end

  private
    def skill_import_params
        params.require(:skill_import).permit(:file)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_skill
      @skill = Skill.find(params[:id])
      skip_authorization
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def skill_params
      params.require(:skill).permit(:name, :skillable_id, :skillable_type, :required)
    end
end
