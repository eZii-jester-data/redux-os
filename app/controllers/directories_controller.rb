# typed: false
class DirectoriesController < ApplicationController
  before_action :set_directory, only: [:show, :edit, :update, :destroy]

  # GET /directories
  # GET /directories.json
  def index
    @directories = Directory.all
  end

  # GET /directories/1
  # GET /directories/1.json
  def show
    case params[:id]
    when /\A\//
      global_dir_path = params[:id]
    when /\Alocal\Z/
      global_dir_path = '/local' + File.expand_path(File.join(Rails.application.root.to_s))
    else
      global_dir_path = params[:id]
    end

    @path = EziiOsPath.new(global_dir_path)

    case @path.file_system.machine_readable_identifier
    when 'local'
      @paths = Dir
        .entries(@path.file_system_path)
        .reject do |entry| 
          entry == '.' || entry == '..'
        end # 
        .map do |entry| 
          
          EziiOsPath.new(
            File.join(@path.global_path, entry)
          )
        end
  
        # .reject do |path| 
        #   path.file_system_path =~ /\/\./
        # end # filter invisible files

    when 'dropbox'
      dropbox_directory = DropboxDirectory.new(@path.file_system_path)
      @paths = dropbox_directory
        .entries
        .take(25)
        .map do |entry|
          path = EziiOsPath.new(
            File.join(@path.global_path, entry['name'])
          )
          path.dropbox_metainfo = entry
          path
        end

    when 'github'
      redirect_to('https://github.com/ezii123/ezii-os/find/master')
    end
  end

  # GET /directories/new
  def new
    @directory = Directory.new
  end

  # GET /directories/1/edit
  def edit
  end

  # POST /directories
  # POST /directories.json
  def create
    @directory = Directory.new(directory_params)

    respond_to do |format|
      if @directory.save
        format.html { redirect_to @directory, notice: 'Directory was successfully created.' }
        format.json { render :show, status: :created, location: @directory }
      else
        format.html { render :new }
        format.json { render json: @directory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /directories/1
  # PATCH/PUT /directories/1.json
  def update
    respond_to do |format|
      if @directory.update(directory_params)
        format.html { redirect_to @directory, notice: 'Directory was successfully updated.' }
        format.json { render :show, status: :ok, location: @directory }
      else
        format.html { render :edit }
        format.json { render json: @directory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /directories/1
  # DELETE /directories/1.json
  def destroy
    @directory.destroy
    respond_to do |format|
      format.html { redirect_to directories_url, notice: 'Directory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

 private
   # Use callbacks to share common setup or constraints between actions.
  def set_directory
    # @directory = Directory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def directory_params
    params.require(:directory).permit(:path)
  end
end
