# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def cretax(name, rank, auth, common, descr, par)
  Taxon.create({scientific_name: name, rank: rank, authority: auth, common_name: common, description: descr, parent_taxon: par})
end

euks = cretax('Eukaryota', 'Domain', 'Margulis,1978', 'Eukaryote', 'Cells or organisms with clearly defined cellular nuclei', nil)
plants = cretax('Plantae', 'Kingdom', nil, 'Plant', 'Green plants', euks)
animals = cretax('Animalia', 'Kingdom', 'Linnaeus, 1758', 'Animal', 'Animals', euks)
arths = cretax('Arthropoda', 'Phylum', 'von Siebold, 1848', 'Arthropod', 'Arthropods', animals)

arachnida = cretax('Arachnida', 'Class', 'Lamarck, 1801', 'Arachnid', 'Eight legged arthropods: spiders, scorpions, harvestmen, ticks, mites and solifuges', arths)
araneae = cretax('Araneae', 'Order', 'Clerck, 1757', 'Spider', 'Air-breathing, eight-legged arthropods with fanged chelicerae that inject venom', arachnida)
jumpers = cretax('Salticidae', 'Family', 'Blackwall, 1841', 'Jumping spider', 'Jumping spiders', araneae)

insects = cretax('Insecta', 'Class', 'Linnaeus, 1758', 'Insect', 'Insects', arths)
hymn = cretax('Hymenoptera', 'Order', 'Linnaeus, 1758', nil, 'Sawflies, wasps, bees and ants', insects)
w_a = cretax('Vespoidea', 'Superfamily', nil, nil, 'Wasps and ants', hymn)
ants = cretax('Formicidae', 'Family', 'Latreille, 1809', 'Ant', 'Ants', w_a)
