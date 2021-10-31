class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_ownership, only: [:show, :edit, :update, :destroy]

  def index
    @images = current_user.images.where(hidden: false)
    @sort = params[:sort]
    case @sort
    when "new"
      @images = @images.order(created_at: :desc)
    when "favorite"
      @images = @images.where(favorite: true)
    when "hidden"
      @images = current_user.images.where(hidden: true)
    else
      @images = @images.order("RANDOM()")
    end
    @title_query = params[:title_query]
    @tag_query = params[:tag_query]

    if @title_query && @title_query != ""
      @images = @images.where("title LIKE ?", "%#{@title_query}%")
    end

    if @tag_query && @tag_query != ""
      case params[:qtype]
      when "any"
        @images = @images.tagged_with(@tag_query, :any => true)
      when "exact"
        @images = @images.tagged_with(@tag_query, :match_all => true)
      when "exclude"
        @images = @images.tagged_with(@tag_query, :exclude => true)
      else
        @images = @images.tagged_with(@tag_query)
      end
    end

    @photos = @images.where(mediatype: "image")
    @videos = @images.where(mediatype: "video")
    @links = @images.where(mediatype: "link")
  end

  def show
    @image = Image.find(params[:id])
  end

  def play # just for videos
    @video = Image.find(params[:id])
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

  def fileupload

  end

  def upload
    if params[:images]
      uploaded_file = params[:images]
      table = CSV.parse(uploaded_file.read)

      table.each do |row|
        next if row[0] == "id" # header row

        if !Image.where(url: row[1]).exists?
          image = current_user.images.new(url: row[1], title: row[2], desc: row[3], favorite: row[4], mediatype: row[8])
          image.save
        end
      end
    end

    if params[:tags] && params[:taggings]
      tags = CSV.parse(params[:tags].read)
      taggings = CSV.parse(params[:taggings].read)

      taggings.each do |row|
        next if row[0] == "id" # header row

        tag_name = tags[row[1].to_i][1] # get name column of tag record with id equal to tag_id (DANGEROUS: assumes tags are in order by id)
        tagged = Image.find(row[3])
        tagged.tag_list.add(tag_name)
        tagged.save
      end
    end

    redirect_to images_path
  end

  private
    def image_params
      params.require(:image).permit(:title, :url, :desc, :mediatype, :favorite, :tag_list, :hidden)
    end
    def verify_ownership
      if Image.find(params[:id]).user_id != current_user.id
        redirect_to images_path
      end
    end
end
