require 'query_utils'


class PhotoFilesController < ApplicationController

    def index
    #@photo_files = PhotoFile.search(params[:q])
    @photo_files = PhotoFile.where(*QueryUtils::params_to_where(query_params))

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"photo_list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def destroy
    @photo_file = PhotoFile.find(params[:id])
    @photo_file.destroy
    # Redirect back to wherever we came from
    redirect_to URI(request.referer).path
  end

  private
  def query_params
    params.permit(:ftype, :photo_id, :width, :height, :path)
  end

end
