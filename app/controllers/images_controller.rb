class ImagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @images = current_user.images
    @query = params[:query]

    if @query
      if @query.include? "favorite"
        @images = @images.where(favorite: true)
        @query.slice! "favorite"
      end
      if @query != ""
        @images = @images.tagged_with(@query)
      end
    end
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = current_user.images.new
  end

  def create
    @image = current_user.images.new(image_params)

    if @image.save
      redirect_to @image
    else
      render :new
    end
  end

  def edit
  end

  private
    def image_params
      params.require(:image).permit(:title, :url, :desc, :mediatype, :favorite, :tag_list)
    end
end
