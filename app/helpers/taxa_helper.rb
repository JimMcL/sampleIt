module TaxaHelper

  # Returns the set of descendants of taxon which have specimens
  def get_interesting_descendants(taxon, limit = 1000)
    desc = taxon.descendants(true, true)
    return desc.count, Taxon.where(id: desc.select(&:id)).order(:scientific_name).limit(limit)
  end
  
end
