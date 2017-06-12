# Class which can be used instead of nil to represent an undefined taxon
class NullTaxon
  def rank
    nil
  end

  def scientific_name
    nil
  end

  def common_name
    nil
  end

  def parent_taxon
    this
  end
  
  def parent_description
    nil
  end
    
  def ancestor_with_rank(rank)
    NullTaxon.new
  end

  def descendants(leaves_only = true)
    []
  end

  def label
    nil
  end

  def choose_photos(limit = 10)
    nil
  end

  def descriptive_text(format = :text)
    nil
  end

  def scientific_name_to_html
    ''
  end

end
