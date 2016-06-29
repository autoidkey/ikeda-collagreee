class ThreadClassesController < ApplicationController
  before_action :set_thread_class, only: [:show, :edit, :update, :destroy]
  before_action :set_theme, only: [:all]
  before_action :set_entry, only: [:set]

  # GET /thread_classes
  # GET /thread_classes.json
  def index
    @thread_classes = ThreadClass.all
  end

  # GET /thread_classes/1
  # GET /thread_classes/1.json
  def show
  end

  def all
    @clasters = Entry.where(theme_id: @theme.id, parent_id: nil).reorder("claster ASC").pluck(:claster).uniq
    if @clasters[0]==nil
      @clasters.shift
    end
    @threads = []
    @clasters.each do |claster|
      if ThreadClass.exists?(claster_id: claster, theme_id: @theme.id)
        array = []
        array[0] = Entry.where(theme_id: @theme.id, parent_id: nil, claster: claster)
        array[1] = ThreadClass.find_by(claster_id: claster, theme_id: @theme.id)
        logger.info({testtest2: array[1]})
        @threads.push(array)
      else
        array = []
        array[0] = Entry.where(theme_id: @theme.id, parent_id: nil, claster: claster)
        array[1] = ""
        @threads.push(array)
      end
    end

    @entry_noclasses = Entry.where(theme_id: @theme.id, parent_id: nil, claster: nil)
    @thread_class_new = ThreadClass.new
    # @threads = Entry.where(theme_id: @theme.id, parent_id: nil).reorder("claster ASC")
  end

  def set 
    if @entry.update(entry_params)
      redirect_to thread_classes_all_path(@entry.theme_id), notice: 'Thread class was successfully updated.' 
    else
      redirect_to thread_classes_all_path(@entry.theme_id), notice: 'Thread class was not successfully updated.' 
    end
  end

  # GET /thread_classes/new
  def new
    @thread_class = ThreadClass.new
  end

  # GET /thread_classes/1/edit
  def edit
  end

  # POST /thread_classes
  # POST /thread_classes.json
  def create
    @thread_class = ThreadClass.new(thread_class_params)

    respond_to do |format|
      if @thread_class.save
        format.html { redirect_to thread_classes_all_path(@thread_class.theme_id), notice: 'Thread class was successfully created.' }
        format.json { render :show, status: :created, location: @thread_class }
      else
        format.html { render :new }
        format.json { render json: @thread_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /thread_classes/1
  # PATCH/PUT /thread_classes/1.json
  def update
    respond_to do |format|
      if @thread_class.update(thread_class_params)
        format.html { redirect_to @thread_class, notice: 'Thread class was successfully updated.' }
        format.json { render :show, status: :ok, location: @thread_class }
      else
        format.html { render :edit }
        format.json { render json: @thread_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /thread_classes/1
  # DELETE /thread_classes/1.json
  def destroy
    @thread_class.destroy
    respond_to do |format|
      format.html { redirect_to thread_classes_url, notice: 'Thread class was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_thread_class
      @thread_class = ThreadClass.find(params[:id])
    end

    def set_theme
      @theme = Theme.find(params[:id])
    end

    def set_entry
      @entry = Entry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def thread_class_params
      params.require(:thread_class).permit(:title, :parent_class, :theme_id, :claster_id)
    end

    def entry_params
      params.require(:entry).permit(:title, :body, :user_id, :parent_id, :np, :theme_id, :image, :facilitation , :claster, :stamp)
    end
end
