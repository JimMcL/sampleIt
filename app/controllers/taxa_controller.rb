class TaxaController < ApplicationController

  def index
    @taxa = Taxon.distinct.
            left_outer_joins(:sites).
            #includes(:sites).
            order(:scientific_name).
            search(params[:q] || params[:term]).
            where(QueryUtils::spatial_query(params))

    # This is a bit tricky. If there was a spatial query, limit mapped sites to those within the spatial query bounds.
    # If we just collect all sites for specimens in @taxa, we end up with sites that are outside the bounds.
    # It could be argued that the unrestricted behaviour is correct, but it is unexpected.
    @taxa_sites = @taxa.collect { |t| t.sites.where(QueryUtils::spatial_query(params)) }.flatten
    
    respond_to do |format|
      format.html
      format.json { render json: @taxa.to_json }
    end
  end

  # Used to provide data for autocomplete on taxon field
  def autocomplete
    @taxa = Taxon.order(:scientific_name).search(params[:term])
    list = @taxa.map {|t| Hash[id: t.id, label: t.label, value: t.scientific_name]}
    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: list.to_json
      end
    end
  end
 
  def show
    @taxon = Taxon.find(params[:id])
  end
 
  def new
    @taxon = Taxon.new
  end
 
  def edit
    @taxon = Taxon.find(params[:id])
  end
 
  def create
    tx_params = maybe_deduce_rank(taxon_params)
    @taxon = Taxon.new(tx_params.except(:parent_taxon_name))

    handle_parent_taxon(@taxon, tx_params)
 
    if @taxon.save
      redirect_to edit_taxon_path @taxon.id
    else
      render 'new'
    end
  end
 
  def update
    @taxon = Taxon.find(params[:id])

    tx_params = handle_parent_taxon(@taxon, taxon_params)
    tx_params = maybe_deduce_rank(tx_params)

    @taxon.update(tx_params)
    redirect_to edit_taxon_path(@taxon.id)
  end
 
  def destroy
    @taxon = Taxon.find(params[:id])
    @taxon.destroy

    alert = @taxon.errors.full_messages.join(', ')
    alert = nil if alert.blank?
    if alert
      # Redirect back to wherever we came from
      redirect_to URI(request.referer).path, alert: alert
    else
      # Referring page won't exist if it was displaying the now-deleted record
      redirect_to taxa_path, notice:  "#{@taxon.label} deleted"
    end
  end
 
  def edit_parent_taxon
    @taxon = Taxon.find(params[:id])
    redirect_to edit_taxon_path(@taxon.parent_taxon_id)
  end
  
  private

  def taxon_params
    params.require(:taxon).permit(:description, :rank, :scientific_name, :common_name, :parent_taxon_id, :parent_taxon_name, :authority)
  end

  def maybe_deduce_rank(params)
    # If rank is not specified, try to deduce it from scientific name
    if params[:rank].blank? && (dd = Taxon.deduce_scientific_name_and_rank_from_name(params[:scientific_name]))
      params[:rank] = dd[1]
    end
    params
  end
  
  def handle_parent_taxon(taxon, tx_params)
    t = Taxon.find_or_create_with_name(tx_params[:parent_taxon_name], Taxon.higher_rank(taxon.rank))
    id = t ? t.id : nil
    
    taxon.parent_taxon_id = id
    tx_params[:parent_taxon_id] = id

    # Remove taxon name from parameters
    tx_params.except(:parent_taxon_name)
  end

end
