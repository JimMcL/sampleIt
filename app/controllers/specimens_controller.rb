require 'csv'
require 'query_utils'

class SpecimensController < ApplicationController

  include HasPhotos
  
  def index
    # Allow either a single q param or specific column values to be specified
    if params.key?(:q)
      # Single parameter - intended for interactive use
      @specimens = Specimen.includes(:taxon).left_outer_joins(:site).
                   order(updated_at: :desc).
                   search(params[:q]).
                   where(QueryUtils::spatial_query(params))
    else
      # Each (whitelisted) parameter is treated as a column name and
      # value.  The query requires rows which satisfy all conditions.
      qry = QueryUtils::params_to_where(query_params, {id: true})
      @specimens = Specimen.includes(:taxon).where(*qry)
    end

    respond_to do |format|
      format.html do
        redirect_to edit_specimen_path(@specimens.first) if params[:shortcut] && @specimens.count == 1
      end
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"specimens.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end
 
  def show
    # Don't want this to exist, but too lazy to scrap it properly
    @specimen = Specimen.find(params[:id])
    render 'edit'
  end
 
  def new
    @specimen = Specimen.new(new_params)
  end
 
  def edit
    @specimen = Specimen.find(params[:id])
  end
 
  def create
    sp_params = specimen_params
    sp_params = handle_taxon(@specimen, sp_params)

    @specimen = Specimen.new(params_for_new(sp_params))
 
    extract_photo(@specimen, sp_params, params)
    
    if @specimen.save
      redirect_to edit_specimen_path(@specimen)
    else
      render 'new'
    end
  end
 
  def update
    @specimen = Specimen.find(params[:id])

    sp_params = extract_photo(@specimen, specimen_params, params)
    sp_params = handle_taxon(@specimen, sp_params) if sp_params

    @specimen.update(sp_params) if sp_params
    # Note that presence method below converts blank to nil
    redirect_to edit_specimen_path(@specimen), alert: @specimen.errors.full_messages.join(', ').presence
  end
 
  def destroy
    @specimen = Specimen.find(params[:id])
    @specimen.destroy
 
    redirect_to specimens_path
  end

  def copy
    @specimen = Specimen.find(params[:id]).dup
    render 'new'
  end
  
  def edit_taxon
    @specimen = Specimen.find(params[:id])
    redirect_to edit_taxon_path(@specimen.taxon_id)
  end
  
  def edit_site
    @specimen = Specimen.find(params[:id])
    redirect_to edit_site_path(@specimen.site_id)
  end

  ##########
  private

  def specimen_params
    params.require(:specimen).permit(:description, :taxon_id, :taxon_name, :site_id,
                                     :quantity, :body_length, :notes, :photo, :exif, :id_confidence,
                                     :other, :disposition)
  end

  def new_params
    params.permit(:site_id)
  end

  def query_params
    params.permit(:id, :description, :site_id, :quantity, :body_length, :notes,
                  :created_at, :updated_at, :taxon_id, :id_confidence,
                  :other, :ref, :disposition)

  end

  def handle_taxon(specimen, sp_params)
    # Assume taxon_name which doesn't match the taxon ID is intended as a new genus or species
    t = Taxon.find_or_create_with_name(sp_params[:taxon_name], :Genus)
    id = t ? t.id : nil
    
    specimen.taxon_id = id if specimen
    sp_params[:taxon_id] = id

    # Remove taxon name from parameters
    sp_params.except(:taxon_name)
  end
end
