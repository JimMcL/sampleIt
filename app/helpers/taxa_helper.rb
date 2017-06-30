module TaxaHelper

  # Returns the set of descendants of taxon which have specimens
  def get_interesting_descendants(taxon)
    desc = taxon.descendants(true, true)
    Taxon.where(id: desc.select(&:id)) 
  end
  
end
