# == Schema Information
#
# Table name: inquiries
#
#  id           :integer          not null, primary key
#  name         :string
#  job_title    :string
#  agency_name  :string
#  email        :string
#  agency_size  :string
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class InquiriesController < ApplicationController
  before_action :set_inquiry, only: [:show, :edit, :update, :destroy]

  # GET /inquiries
  # GET /inquiries.json
  def index
    @inquiries = Inquiry.all
    skip_authorization
  end

  # GET /inquiries/1
  # GET /inquiries/1.json
  def show
    skip_authorization
  end

  # GET /inquiries/new
  def new
    @inquiry = Inquiry.new
    skip_authorization
  end

  # GET /inquiries/1/edit
  def edit
    skip_authorization
  end

  # POST /inquiries
  # POST /inquiries.json
  def create
    @inquiry = Inquiry.new(inquiry_params)
  skip_authorization
    respond_to do |format|
      if @inquiry.save
        if ENV['RAILS_ENV'] == "production"
          format.html { redirect_to "http://demo.inclustaff.com", notice: "Thanks for your interest! We'll be contacting you shortly. In the mean time, take our demo out for a spin!" }
          format.json { render :show, status: :created, location: @inquiry }
        else
          format.html { redirect_to "http://demo.inclustaff-bhicks8364.c9.io", notice: "Thanks for your interest! We'll be contacting you shortly. In the mean time, take our demo out for a spin!" }
          format.json { render :show, status: :created, location: @inquiry }
        end
      else
        format.html { render :new }
        format.json { render json: @inquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inquiries/1
  # PATCH/PUT /inquiries/1.json
  def update
    skip_authorization
    respond_to do |format|
      if @inquiry.update(inquiry_params)
        format.html { redirect_to @inquiry, notice: 'Inquiry was successfully updated.' }
        format.json { render :show, status: :ok, location: @inquiry }
      else
        format.html { render :edit }
        format.json { render json: @inquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inquiries/1
  # DELETE /inquiries/1.json
  def destroy
    skip_authorization
    @inquiry.destroy
    respond_to do |format|
      format.html { redirect_to inquiries_url, notice: 'Inquiry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inquiry
      @inquiry = Inquiry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inquiry_params
      params.require(:inquiry).permit(:name, :job_title, :agency_name, :email, :agency_size, :phone_number)
    end
end
