# typed: false
class GltfModelsController < ApplicationController
  before_action :set_gltf_model, only: [:show, :edit, :update, :destroy, :bin, :texture]

  # GET /gltf_models
  # GET /gltf_models.json
  def index
    @gltf_models = GltfModel.all
  end

  # GET /gltf_models/1
  # GET /gltf_models/1.json
  def show

    path = @gltf_model.global_path
        fail path

    path = path.match(/\/storage.*/)[0]

    path = File.join('local', Rails.application.root.to_s, path)

    respond_to do |format|
      format.gltf do
        send_file EziiOsPath.new(path).file_system_path
      end
    end
  end
  
  def bin
    respond_to do |format| 
      format.bin do
        send_file EziiOsPath.new(@gltf_model.bin_global_path).file_system_path
      end
    end
  end
  
  def texture
    respond_to do |format|
      §(USING_FORMAT_JPG_INSTEAD_OF_JPEG_CAUSES => [SystemStackError, "stack level too deep"]) do
        format.jpeg do
          path = nil
          jpg = EziiOsPath.new(
            File.join(
              @gltf_model.textures_directory_global_path,
              params[:texture_file_name] + '.jpg'
            )
          )   
                    
          jpeg = EziiOsPath.new(
            File.join(
              @gltf_model.textures_directory_global_path,
              params[:texture_file_name] + '.jpeg'
            )
          )
          
          if jpg.file?
            path = jpg.file_system_path
          elsif jpeg.file?      
            path = jpeg.file_system_path
          end
          
          if path.nil? 
            fail "no file found"
          else
           send_file path
         end
        end
      end
      
      format.png do
        send_file EziiOsPath.new(
          File.join(
            @gltf_model.textures_directory_global_path,
            params[:texture_file_name] + '.png'
          )
        ).file_system_path
      end
    end
  end

  # GET /gltf_models/new
  def new
    @gltf_model = GltfModel.new
  end

  # GET /gltf_models/1/edit
  def edit
  end

  # POST /gltf_models
  # POST /gltf_models.json
  def create
    @gltf_model = GltfModel.new(gltf_model_params)

    respond_to do |format|
      if @gltf_model.save
        format.html { redirect_to @gltf_model, notice: 'Gltf model was successfully created.' }
        format.json { render :show, status: :created, location: @gltf_model }
      else
        format.html { render :new }
        format.json { render json: @gltf_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gltf_models/1
  # PATCH/PUT /gltf_models/1.json
  def update
    respond_to do |format|
      if @gltf_model.update(gltf_model_params)
        format.html { redirect_to @gltf_model, notice: 'Gltf model was successfully updated.' }
        format.json { render :show, status: :ok, location: @gltf_model }
      else
        format.html { render :edit }
        format.json { render json: @gltf_model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gltf_models/1
  # DELETE /gltf_models/1.json
  def destroy
    @gltf_model.destroy
    respond_to do |format|
      format.html { redirect_to gltf_models_url, notice: 'Gltf model was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gltf_model
      if params[:id] != 'scene'
        @gltf_model = GltfModel.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gltf_model_params
      params.require(:gltf_model).permit(:global_path, :bin_global_path, :textures_directory_global_path)
    end
end
