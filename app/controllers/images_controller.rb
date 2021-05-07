class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_ownership, except: :index

  def index
    @images = current_user.images.order(id: :asc)
    @query = params[:query]

    if @query
      case params[:qtype]
      when "any"
        @images = @images.tagged_with(@query, :any => true)
      when "exact"
        @images = @images.tagged_with(@query, :match_all => true)
      when "exclude"
        @images = @images.tagged_with(@query, :exclude => true)
      else
        @images = @images.tagged_with(@query)
      end
    end

    # if @query
    #   if @query.include? "favorite"
    #     @images = @images.where(favorite: true)
    #     @query.slice! "favorite"
    #   end
    #   if @query != ""
    #     @images = @images.tagged_with(@query)
    #   end
    # end

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
    @image.tag_list.add("favorite") if @image.favorite

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
      if @image.favorite
        @image.tag_list.add("favorite")
      else
        @image.tag_list.remove("favorite")
      end
      @image.save
      redirect_to images_path # edit_image_path(params[:id].to_i + 1)
    else
      render :edit
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy

    redirect_to images_path
  end

  def upload
    uploaded_file = params[:file]
    table = CSV.parse(uploaded_file.read)

    table.each do |row|
      next if row[0] == "id" # header row

      if !Image.where(url: row[1]).exists?
        image = current_user.images.new(url: row[1], title: row[2], desc: row[3], favorite: row[4], mediatype: row[8])
        image.save
      end
    end

    redirect_to images_path
  end

  private
    def image_params
      params.require(:image).permit(:title, :url, :desc, :mediatype, :favorite, :tag_list)
    end
    def verify_ownership
      if Image.find(params[:id]).user_id != current_user.id
        redirect_to images_path
      end
    end
end
