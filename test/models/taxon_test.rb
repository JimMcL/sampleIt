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
#

require 'test_helper'

class TaxonTest < ActiveSupport::TestCase

  test "cleanup morphospecies" do
    all = Taxon.all.count
    puts "Before: #{all} taxa"
    f = Taxon.where(scientific_name: 'Salticidae').first
    ms = f.generate_morphospecies
    puts "With morphospecies: #{Taxon.all.count}"
    assert_equal 1, Taxon.where(scientific_name: ms.scientific_name).count, "Unique morpospecies not generated correctly"
    Taxon.cleanup_morphotaxa
    assert_equal 0, Taxon.where(scientific_name: ms.scientific_name).count, "Morphospecies not removed correctly"
    assert_equal all, Taxon.all.count, "Morphospecies not cleaned up correctly"
  end
  
  test "generate morphospecies" do
    # Can't generate a morphospecies within species or subspecies
    ss = Taxon.where(scientific_name: 'Metacyrba taeniola similis').first
    assert_equal :Subspecies, ss.rank
    assert_raise { ss.generate_morphospecies }

    s = Taxon.where(scientific_name: 'Myrmarachne luctuosa').first
    assert_equal :Species, s.rank
    assert_raise { s.generate_morphospecies }

    # Can generate for genus or above
    g = Taxon.where(scientific_name: 'Myrmarachne').first
    assert_equal :Genus, g.rank
    check_morphospecies(g, 'Myrmarachne sp1', true)
    check_morphospecies(g, 'Myrmarachne sp2', true)
    check_morphospecies(g, 'Myrmarachne sp3', true)

    f = Taxon.where(scientific_name: 'Salticidae').first
    assert_equal :Family, f.rank
    check_morphospecies(f, 'Salticid1 sp1', false)
    check_morphospecies(f, 'Salticid2 sp1', false)
    check_morphospecies(f, 'Salticid3 sp1', false)

    # Parent-less genus
    g = Taxon.where(scientific_name: 'Metacyrba').first
    assert_equal :Genus, g.rank
    check_morphospecies(g, 'Metacyrba sp1', true)
    check_morphospecies(g, 'Metacyrba sp2', true)

    # Order genus
    o = Taxon.where(scientific_name: 'Hymenoptera').first
    assert_equal :Order, o.rank
    check_morphospecies(o, 'Hymenoptera1 sp1', false)
    check_morphospecies(o, 'Hymenoptera2 sp1', false)
  end

  test "case sensitive rank" do
    assert_equal 1, Taxon.where(scientific_name: 'Vespoida').length
    nr = Taxon.find_or_create_with_name('Vespoida (SuperFamily)')
    assert_equal 1, Taxon.where(scientific_name: 'Vespoida').length
  end
  
  test "descriptive_text" do
    t1 = Taxon.create(:scientific_name => 'Dolichoderus clarki')
    assert_equal 'Dolichoderus clarki', t1.descriptive_text
    t2 = Taxon.create(:common_name => 'Golden bum')
    assert_equal 'Golden bum', t2.descriptive_text
    t3 = Taxon.create(:scientific_name => 'Dolichoderus clarki', :common_name => 'Golden bum')
    assert_equal 'Golden bum (Dolichoderus clarki)', t3.descriptive_text
  end
  
  test "rank deduction" do
    assert_nil Taxon.deduce_scientific_name_and_rank_from_name(nil)
    assert_equal 'Genus', Taxon.deduce_scientific_name_and_rank_from_name('Genus')[0]
    assert_nil Taxon.deduce_scientific_name_and_rank_from_name('Genus')[1]
    assert_equal 'Animalia', Taxon.deduce_scientific_name_and_rank_from_name('animalia (Kingdom)')[0]
    assert_equal :Kingdom, Taxon.deduce_scientific_name_and_rank_from_name('animalia (Kingdom)')[1]
    assert_nil Taxon.deduce_scientific_name_and_rank_from_name('animalia')[1]
    assert_equal 'Genus species', Taxon.deduce_scientific_name_and_rank_from_name('Genus species')[0]
    assert_equal :Species, Taxon.deduce_scientific_name_and_rank_from_name('Genus species')[1]
    assert_equal 'Genus species sub', Taxon.deduce_scientific_name_and_rank_from_name('Genus species sub')[0]
    assert_equal :Subspecies, Taxon.deduce_scientific_name_and_rank_from_name('Genus species sub')[1]
  end

  test "creation with scientific name" do
    gn = 'Panthera'
    spn = "#{gn} tigris"
    sspn1 = "#{spn} tigris"
    sspn2 = "#{spn} altaica"
    assert_equal 0, Taxon.where(scientific_name: gn, rank: :Genus).length, "Genus #{gn} shouldn't exist but does"
    assert_equal 0, Taxon.where(scientific_name: spn, rank: :Species).length, "Species #{spn} shouldn't exist but does"
    assert_equal 0, Taxon.where(scientific_name: sspn1, rank: :Subspecies).length, "Subspecies #{spn} shouldn't exist but does"
    sp = Taxon.find_or_create_with_name(sspn1, :Genus)
    assert_equal 1, Taxon.where(scientific_name: gn, rank: :Genus).length, "Genus #{gn} should exist but doesn't"
    assert_equal 1, Taxon.where(scientific_name: spn, rank: :Species).length, "Species #{spn} should exist but doesn't"
    assert_equal 1, Taxon.where(scientific_name: sspn1, rank: :Subspecies).length, "Subspecies #{spn} should exist but doesn't"
    assert_equal spn, Taxon.where(scientific_name: sspn1, rank: :Subspecies).first.parent_taxon.scientific_name, "Subpecies #{sspn1} has wrong parent taxon"
    assert_equal gn, Taxon.where(scientific_name: spn, rank: :Species).first.parent_taxon.scientific_name, "Species #{spn} has wrong parent taxon"

    sp2 = Taxon.find_or_create_with_name(sspn2)
    assert_equal 1, Taxon.where(scientific_name: gn, rank: :Genus).length, "Genus #{gn} should exist (once) but doesn't"
    assert_equal 1, Taxon.where(scientific_name: spn, rank: :Species).length, "Species #{spn} should exist (once) but doesn't"
    assert_equal 1, Taxon.where(scientific_name: sspn2, rank: :Subspecies).length, "Subspecies #{spn} should exist but doesn't"
    assert_equal spn, Taxon.where(scientific_name: sspn2, rank: :Subspecies).first.parent_taxon.scientific_name, "Subpecies #{sspn1} has wrong parent taxon"
    assert_equal gn, Taxon.where(scientific_name: spn, rank: :Species).first.parent_taxon.scientific_name, "Species #{spn} has wrong parent taxon"

    sp3 = Taxon.find_or_create_with_name(sspn2)
    assert_equal 1, Taxon.where(scientific_name: sspn2, rank: :Subspecies).length, "Subspecies #{spn} should exist (once) but doesn't"

    sp4 = Taxon.find_or_create_with_name(sp3.label)
    assert_equal sp3.label, sp4.label, "Creation with label failed"

    l5 = "Animalia (Kingdom)"
    sp5 = Taxon.find_or_create_with_name(l5)
    assert_equal :Kingdom, sp5.rank, "Creation with rank failed"
    assert_equal l5, sp5.label, "Creation with label and rank failed"

    par1 = Taxon.find_or_create_with_name(sp2.parent_taxon.label, Taxon.higher_rank(sp2.rank))
    assert_equal sp2.parent_taxon_id, par1.id, "Find or create of parent taxon didn't find existing taxon"
    par2 = Taxon.find_or_create_with_name(par1.parent_taxon.label, Taxon.higher_rank(par1.rank))
    assert_equal par1.parent_taxon_id, par2.id, "Find or create of parent taxon didn't find existing taxon"
  end

  test "rank manipulations" do
    assert_equal :Genus, Taxon.higher_rank(:Species)
    assert_equal :Genus, Taxon.higher_rank('Species')
    assert_equal :Subspecies, Taxon.lower_rank(:Species)
    assert_equal :Subspecies, Taxon.lower_rank('Species')
    assert_nil Taxon.lower_rank(:Subspecies)
    assert_nil Taxon.higher_rank(:Domain)
    assert_nil Taxon.higher_rank(:fred)
  end

  test "taxon tree" do
    t1 = Taxon.find_or_create_with_name('Myrmecia brevinoda')
    t2 = Taxon.find_or_create_with_name('Myrmecia gulosa')
    assert_not_nil t1.parent_taxon_id, "Missing parent"
    assert_equal t1.parent_taxon_id, t2.parent_taxon_id, "Parents differ"
    g = t1.parent_taxon
    sf = create_parent(g, 'Myrmeciinae')
    f = create_parent(sf, 'Formicidae')
  end

  test "skipped levels" do
    g = Taxon.find_or_create_with_name('Earwig', :Genus)
    assert_equal :Genus, g.rank
    assert_nil g.parent_taxon
    f = Taxon.find_or_create_with_name("EarwigFamily1", :Family)
    assert_equal :Family, f.rank
    g.parent_taxon = f
    g.save!

    # Check that re-creating parent does the right thing
    par1 = create_parent(g, g.parent_taxon.label)
    assert_equal :Family, par1.rank
    assert_equal g.parent_taxon.scientific_name, par1.scientific_name
  end

  test "labels" do
    assert_nil Taxon.parse_label(nil)
    assert_nil Taxon.parse_label('')
    assert_nil Taxon.parse_label('fred')
    assert_equal 'Fred', Taxon.parse_label('fred (mary)')[0]
    assert_equal 'Fred', Taxon.parse_label(' fred (mary)')[0]
    assert_equal 'Fred', Taxon.parse_label('fred (mary) ')[0]
    assert_equal 'Fred', Taxon.parse_label(' fred (mary) ')[0]
    assert_equal :Mary, Taxon.parse_label('fred (mary)')[1]
    assert_equal 'One two', Taxon.parse_label('one two (rank)')[0]
    assert_equal :Rank, Taxon.parse_label('one two (rank)')[1]
    assert_equal 'One two three', Taxon.parse_label('one two three (rank)')[0]
    assert_equal :Rank, Taxon.parse_label('one two (rank)')[1]
    assert_nil Taxon.parse_label('one two three four (rank)')
    assert_nil Taxon.parse_label('one two three(rank)')
    assert_nil Taxon.parse_label('one two three (rank')
    assert_nil Taxon.parse_label('one (two) (rank')
  end

  test "descendants" do
    gn = 'Panthera'
    spn = "#{gn} tigris"
    sspn1 = "#{spn} tigris"
    sspn2 = "#{spn} altaica"
    ssp1 = Taxon.find_or_create_with_name(sspn1)
    ssp2 = Taxon.find_or_create_with_name(sspn2)
    sp = Taxon.find_or_create_with_name(spn)
    g = Taxon.find_or_create_with_name(gn)

    # Should be the 2 sub species in the result
    assert_empty [sspn1, sspn2] - descendant_names(g, true)
    # Should be all 4 taxa in the result
    assert_empty [sspn1, sspn2, spn, gn] - descendant_names(g, false)
    # Should be all 1 taxon in the result, regardless of leaves_only value
    assert_empty [sspn1] - descendant_names(ssp1, true)
    assert_empty [sspn1] - descendant_names(ssp1, false)
    
  end

  ################################################################################

  def descendant_names(taxon, leaves_only)
    taxon.descendants(leaves_only).map(&:scientific_name)
  end
  
  def create_parent(taxon, par_name)
    Taxon.find_or_create_with_name(par_name, Taxon.higher_rank(taxon.rank))
  end

  def dump_taxon(t)
    if t.blank?
      0
    else
      indent = dump_taxon(t.parent_taxon)
      puts (' ' * indent * 2) + t.label
      indent + 1
    end
  end

  def check_morphospecies(parent, expected_name, parent_is_genus)
    ms = parent.generate_morphospecies
    assert_equal :Species, ms.rank
    assert_equal expected_name, ms.scientific_name
    assert_equal :Genus, ms.parent_taxon.rank
    if parent_is_genus
      assert_equal parent.id, ms.parent_taxon_id, "Incorrect genus for generated morphospecies #{ms.scientific_name}"
      if parent.parent_taxon_id.nil?
        assert_nil ms.parent_taxon.parent_taxon_id, "Incorrect grandparent for generated morphospecies #{ms.scientific_name}"
      else
        assert_equal parent.parent_taxon_id, ms.parent_taxon.parent_taxon_id, "Incorrect grandparent for generated morphospecies #{ms.scientific_name}"
      end
    else
      assert_equal parent.id, ms.parent_taxon.parent_taxon_id, "Incorrect parent for genus of generated morphospecies #{ms.scientific_name}"
    end

    # Check for infinite loop
    t = ms
    infinity = 10
    for depth in 1..infinity do
      break if t.nil?
      t = t.parent_taxon
      assert depth < infinity - 1
    end

    ms
  end
  
end
