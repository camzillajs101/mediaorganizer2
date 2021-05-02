class TagsController < ApplicationController
  def index
    @tags = ActsAsTaggableOn::Tag.all.order(id: :asc)
  end
end
