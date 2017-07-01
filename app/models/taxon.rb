# == Schema Information
#
# Table name: taxa
#
#  id              :integer          not null, primary key
#  description     :text
#  scientific_name :text
#  common_name     :text
#  parent_taxon_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  rank            :text
#  authority       :string
#
# Indexes
#
#  index_taxa_on_parent_taxon_id  (parent_taxon_id)
#

class Taxon < ApplicationRecord
  belongs_to :parent_taxon, class_name: "Taxon", optional: true
  has_many :sub_taxa, -> { order(:scientific_name) }, class_name: "Taxon", foreign_key: "parent_taxon_id",
           :dependent => :restrict_with_error
  has_many :specimens, :dependent => :restrict_with_error
  has_many :photos, through: :specimens
  has_many :sites, through: :specimens
  
  def self.common_ranks
    # Ugly hack since there are really more ranks but no way for a user to add one
    [:Domain, :Kingdom, :Phylum, :Class, :Subclass, :Order, :Suborder, :SuperFamily, :Family, :SubFamily, :Tribe, :Genus, :Species, :Subspecies]
  end

  def self.higher_rank(rank)
    relative_rank(rank, -1)
  end

  def self.lower_rank(rank)
    relative_rank(rank, 1)
  end

  def self.relative_rank(rank, inc)
    idx = rank_index(rank)
    if !idx.nil?
      ridx = idx + inc
      ridx < 0 ? nil : common_ranks[ridx]
    end
  end
  
  def self.search(q)
    result = false
    if q.blank?
      result = all
    else
      q.strip! if q
      if lbl = parse_label(q)
        result = where("taxa.scientific_name = ? AND taxa.rank = ?", lbl[0], lbl[1])
      else
        # Accept "Ants" as a search for all sub-taxa of Formicidae
        sin = q.singularize.downcase
        plural = sin.pluralize
        if plural == q.downcase
          ancestors = Taxon.where("lower(taxa.scientific_name) = ? OR lower(taxa.scientific_name) = ? OR lower(taxa.common_name) = ?", q.downcase, sin, sin)
          if ancestors.count == 1
            root = Taxon.find(ancestors.first.id)
            result = Taxon.where("taxa.id in (?)", root.descendants.collect(&:id))
          end
        end

        # Normal search across lots of fields
        if !result
          # lk = "%#{q}%"
          # where("taxa.scientific_name LIKE ? OR taxa.common_name LIKE ? OR taxa.rank LIKE ? OR taxa.description like ?", lk, lk, lk, lk)
          result = where(QueryUtils::q_to_where(q, 'taxa', [], [:scientific_name, :common_name, :rank, :description]))
        end
      end
    end
    result                     
  end

  # Strictly parses a string in the format of #label.
  # Value - [scientific-name, rank] or nil
  def self.parse_label(label)
    re = %r{^
         \s*
         (?<sci>[[:word:]]+(\s+[[:word:]]+){0,2})
         \s+\((?<rank>[[:alpha:]]++)\)
         \s*
         $}x
    if m = re.match(label)
      [m[:sci].capitalize, m[:rank].strip.capitalize.to_sym]
    end
  end

  # Finds or creates a new taxon instance based on a name.  Name may look like a label
  # (i.e. "<scientific name> (<rank>)"), or else "genus[ species[ subspecies]]". If
  # rank is subspecies or species, the taxon will be given an appropriate parent taxon.
  def self.find_or_create_with_name(name, suggested_rank = nil)
    #puts "find_or_create_with_name(#{name}, #{suggested_rank})"
    if deduced = deduce_scientific_name_and_rank_from_name(name)
      #puts "deduced: #{deduced}"
      find_or_create deduced[0], deduced[1], suggested_rank
    end
  end

  # Returns [<name>, <rank>] where <rank> may be nil
  def self.deduce_scientific_name_and_rank_from_name(name)
    # First check for a label format "scientific name (rank)"
    if lbl = parse_label(name)
      lbl
    elsif /\s*[a-z]+(\s+[a-z]+){0,2}\s*/i.match(name)
      # Assume it's just a scientific name. Determine rank from number of words 
      parts = name.split(' ')
      rank = parts.length == 3 ? :Subspecies : parts.length == 2 ? :Species : nil
      [name.strip.capitalize, rank]
    end
  end

  # Deletes any unused morpho-taxa.
  # Morpho-taxa names are assumed to end in digits
  def self.cleanup_morphotaxa
    loop do 
      q = Taxon.where("(scientific_name LIKE '%0' 
                        OR scientific_name LIKE '%1' 
                        OR scientific_name LIKE '%2' 
                        OR scientific_name LIKE '%3' 
                        OR scientific_name LIKE '%4' 
                        OR scientific_name LIKE '%5' 
                        OR scientific_name LIKE '%6' 
                        OR scientific_name LIKE '%7' 
                        OR scientific_name LIKE '%8' 
                        OR scientific_name LIKE '%9') 
                       AND NOT EXISTS (SELECT * FROM taxa AS t2 WHERE t2.parent_taxon_id = taxa.id) 
                       AND NOT EXISTS (SELECT * FROM specimens WHERE taxon_id = taxa.id)").destroy_all
      break if q.empty?
    end
  end

  # Override rank getter to return a symbol
   def rank
     r = self.attributes['rank']
     r ? r.to_sym : r
   end
   
  def parent_description
    (parent_taxon && parent_taxon.description) || ""
  end

  def ancestor_with_rank(rank)
    if self.rank == rank
      self
    elsif parent_taxon.nil?
      Taxon.new
    else
      parent_taxon.ancestor_with_rank(rank)
    end
  end

  def descendants(leaves_only = true, with_specimens_only = false)
    children = sub_taxa
    include_self = !with_specimens_only || specimens.any?
    if children.empty?
      include_self ? [self] : []
    else
      (leaves_only || !include_self ? [] : [self]) + children.map { |st| st.descendants(leaves_only, with_specimens_only) }.flatten
    end
  end

  # See also #parse_label
  def label
    rk = rank.blank? ? '' : " (#{rank})"
    "#{scientific_name}#{rk}"
  end

  def choose_photos(limit = 10)
    # Start with extras to make it more likely we get the best of all angles
    candidates = photos.order(rating: :desc).limit(limit * 2)
    if candidates.length > 0
      # Try to get a selection of good shots of different angles
      by_angle = Hash.new {|h,k| h[k]=[]}
      candidates.each { |p| by_angle[p.view_angle] << p }
      good = by_angle.keys.sort.map { |a| by_angle[a].first }[0..(limit-1)].presence
      # Now get desired number of photos by randomly selecting from the remainder
      others = []
      if good.length < limit && good.length < candidates.length
        others = (candidates - good).sample(limit - good.length)
      end
      good + others
    end
  end

  # Attempts to return "common name (scientific name)"
  def descriptive_text(format = :text)
    has_common_name = !common_name.blank?
    has_scientific_name = !scientific_name.blank?

    cn = common_name ? common_name.capitalize : ''
    sn = scientific_name ? scientific_name.capitalize : ''
    
    if has_common_name && has_scientific_name
        sprintf(format == :html ? '%s (<i>%s</i>)' : '%s (%s)', cn, sn)
    elsif has_common_name
      cn
    elsif has_scientific_name
      format == :html ? "<i>#{sn}</i>" : sn
    else
      # Fallback to description
      description
    end
  end

  # Creates a new taxon with rank :Species and which belongs to this taxon
  def generate_morphospecies
    # Sanity check
    raise "Unable to create a morphospecies within a #{rank}" if Taxon::rank_index(:Species) <= Taxon::rank_index(rank)

    # A few specific rules to make a sensible species name
    if rank == :Genus
      fmt = "#{scientific_name} sp%d"
    else
      genus = "#{scientific_name}%d"
      if rank == :Family
        # Convert family Salticidae to genus Salticid1.
        # Not sure if this is just a convention for animals.
        # Also don't know if there are other applicable conventions
        genus = "#{scientific_name.sub(/idae$/, 'id')}%d"
      end
      fmt = "#{genus} sp1"
    end

    # Now ensure the species name doesn't already exist
    counter = 0
    new_name = ''
    loop do
      counter += 1
      new_name = sprintf(fmt, counter)
      break if !Taxon.exists?(scientific_name: new_name)
    end

    # Create the new species and  possibly genus
    t = Taxon::find_or_create(new_name, :Species, nil)
    # If the genus doesn't have a parent...
    par = t.parent_taxon || NullTaxon.new
    unless par.parent_taxon || par.id == id # Avoid creating infinite loop in taxon hierarchy
      # set it to this
      par.parent_taxon_id = id
      par.save!
    end

    t
  end

  def to_s
    label
  end

  def scientific_name_to_html
    [:Genus, :Species, :Subspecies].include?(rank) ? "<i>#{scientific_name}</i>" : scientific_name
  end
  
  #################################################################################
  private

  # Attempts to find or create a taxon with the specified scientific name and taxon.
  # If it's a sub-species or species, also finds or creates parent taxa up to Genus.
  # rank - the rank if it known, otherwise nil
  # suggested_rank - possible rank, if a matching scientific name with a different (but
  #                  less specific) rank is found, it will be returned, otherwise a new
  #                  taxon will be created with scientific and suggested_rank
  def self.find_or_create(scientific_name, rank, suggested_rank)
    #puts "find_or_create(#{scientific_name}, #{rank}, #{suggested_rank})"
    scientific_name = scientific_name.strip
    unless scientific_name.blank?
      if rank.blank?
        t = lax_find_or_create(scientific_name, suggested_rank)
      else
        # Use "like" rather than "=" because it is case-insensitive
        t = Taxon.where("scientific_name = ? AND rank like ?", scientific_name, rank).first_or_create do |t|
          # Have to explicitly set these values since first_or_create has no values to
          # work with when a where clause is used to find the record (rather than the
          # form ... rank: rank ...)
          t.scientific_name = scientific_name
          t.rank = rank
        end
      end
      if t.parent_taxon_id.nil? && [:Subspecies, :Species].include?(t.rank) && (m = /(.*)\s+\w+/.match(scientific_name))
        t.parent_taxon = find_or_create(m[1], nil, higher_rank(t.rank))
        t.save!
      end
      t
    end
  end

  # Searches for a taxon with the spcified name
  def self.lax_find_or_create(scientific_name, suggested_rank)
    #puts "lax_find_or_create(#{scientific_name}, #{suggested_rank})"
    # Find all matching names
    t = Taxon.where(scientific_name: scientific_name)
    if t.length == 0
      # No matching names - just create a new taxon
      Taxon.create(scientific_name: scientific_name, rank: suggested_rank)
    else
      # Try to pick the closest - but less specific - match
      suggested_idx = rank_index(suggested_rank)
      # Keep only more general ranks
      if !suggested_rank.nil?
        t = t.select {|t| (ri = rank_index(t.rank)).nil? || (ri <= suggested_idx)}
      end
      # Sort on rank - more general first
      t = t.sort {|a, b| rank_index(a.rank) <=> rank_index(b.rank) }
      if t.empty?
        Taxon.create(scientific_name: scientific_name, rank: suggested_rank)
      else
        t.last
      end
    end
  end

  def self.rank_index(rank)
    rank ? common_ranks.map(&:to_s).map(&:downcase).index(rank.to_s.downcase) : nil
  end
  
  def self.rank_diff(rank1, rank2)
    idx1 = rank_index rank1
    idx2 = rank_index rank2
    (idx1.nil? || idx2.nil?) ? nil : idx1 - idx2
  end
  
end
