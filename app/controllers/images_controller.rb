class ImagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @images = current_user.images.order(id: :asc)
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

    @photos = @images.where(mediatype: "image")
    @videos = @images.where(mediatype: "video")
    @links = @images.where(mediatype: "link")
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
    @image = Image.find(params[:id])
  end

  def update
    @image = Image.find(params[:id])

    if @image.update(image_params)
      redirect_to edit_image_path(params[:id].to_i + 1)
    else
      render :edit
    end
  end

  def upload
    uploaded_file = params[:file]
    table = CSV.parse(uploaded_file.read)

    table.each do |row|
      if row[1] = "url" return
      if Image.where(url: row[1]).empty?
        image = current_user.images.new(url: row[1], title: row[2], favorite: row[3], mediatype: row[6])
        image.save
      end
    end

    redirect_to images_path
  end

  private
    def image_params
      params.require(:image).permit(:title, :url, :desc, :mediatype, :favorite, :tag_list)
    end
end
