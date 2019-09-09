class TinymceAssetsController < ApplicationController
  respond_to :json

  def create
    image = TinymceImage.create params.slice(:file, :alt, :hint)
    geometry = Paperclip::Geometry.from_file image.file.path(:large)

    render json: {
      image: {
        url:    image.file.url(:large),
        height: geometry.height.to_i,
        width:  geometry.width.to_i
      }
    }, layout: false, content_type: "text/html"

  end
end