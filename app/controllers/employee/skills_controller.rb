class Employee::SkillsController < ApplicationController
  before_action :set_skill, only: [:show, :edit, :update, :destroy]
  layout 'employee'
  # GET /skills
  # GET /skills.json
  def index
    @order_skills = Skill.job_order.includes(:skillable).order(:name)
    @skills = Skill.all
    gon.skills = @shifts
    @emp_skills = Skill.employee.includes(:skillable).order(:name)
    skip_authorization
  end

  # GET /skills/1
  # GET /skills/1.json
  def show
  end

  # GET /skills/new
  def new
    @employee = current_user.employee
    @skill = @employee.skills.new
    
    skip_authorization
  end

  # GET /skills/1/edit
  def edit
  end

  # POST /skills
  # POST /skills.json
  def create
    @employee = current_user.employee
    @skill = @employee.skills.new(skill_params)
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

  private
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
