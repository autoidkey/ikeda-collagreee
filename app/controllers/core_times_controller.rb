class CoreTimesController < ApplicationController
  before_action :set_core_time, only: [:show, :edit, :update, :destroy]

  # GET /core_times
  # GET /core_times.json
  def index
    @core_times = CoreTime.all
  end

  # GET /core_times/1
  # GET /core_times/1.json
  def show
  end

  # GET /core_times/new
  def new
    @core_time = CoreTime.new
    @themes = Theme.all
  end

  # GET /core_times/1/edit
  def edit
    @themes = Theme.all
  end

  # POST /core_times
  # POST /core_times.json
  def create
    @core_time = CoreTime.new(core_time_params)

    respond_to do |format|
      if @core_time.save
        format.html { redirect_to users_path, notice: 'Core time was successfully created.' }
        format.json { render :show, status: :created, location: @core_time }
      else
        format.html { render :new }
        format.json { render json: @core_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /core_times/1
  # PATCH/PUT /core_times/1.json
  def update
    respond_to do |format|
      if @core_time.update(core_time_params)
        format.html { redirect_to users_path, notice: 'Core time was successfully updated.' }
        format.json { render :show, status: :ok, location: @core_time }
      else
        format.html { render :edit }
        format.json { render json: @core_time.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /core_times/1
  # DELETE /core_times/1.json
  def destroy
    @core_time.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'Core time was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_core_time
      @core_time = CoreTime.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def core_time_params
      params.require(:core_time).permit(:theme_id, :start_at, :end_at, :notice)
    end
end
