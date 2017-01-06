# Imports my BIOL702 csv files and photos
#
# To run:
# bin/rails runner -e production lib/import.rb
class Import
  def import_sites(file, horiz_err = 10)
    
    CSV.foreach(file, headers: true) do |row|
      title = ['1', '2'].include?(row['Transect']) ?
               (row['Notes'] == 'Ad hoc' ? 'BIOL702 ad-hoc' : 'BIOL702') :
                'BIOL702 preparation'
      proj = Project.search(title).first
      atts = {notes: row['Notes'],
              latitude: row['Latitude'],
              longitude: row['Longitude'],
              horizontal_error: horiz_err,
              altitude: row['Altitude'],
              temperature: row['Temperature'],
              weather: row['Weather'],
              collector: row['Collector'],
              sample_type: row['Sample.type'],
              transect: row['Transect'],
              duration: row['Sample.time..mins.'].to_i * 60,
              started_at: DateTime.strptime(row['Date'] + ' ' + row['Time'], '%Y-%m-%d %H:%M'),
              description: row['X'],
              project_id: proj.id,
              ref: row['Site.ID']}
      Site.create(atts)
    end
  end

  def import_site_photos(dir)
    sites_dir = Pathname.new(dir).join('*')
    g = Pathname.glob(sites_dir.join("location.jpg")) + Pathname.glob(sites_dir.join("location.jpg"))
    g.uniq.each do |filename|
      parts = filename.each_filename.to_a
      site_ref = parts[-2].to_i
      site = Site.where('ref = ?', site_ref).first
      site = Site.where('ref = ?', "#{site_ref}a").first unless site

      photo = Photo.create_from_io(File.open(filename), filename.to_s, 'image/jpeg', nil, false)
      site.photos << photo
      site.save!
    end
  end

  def add_to_family(taxon, family_name)
    if taxon && [:Species, :Subspecies].include?(taxon.rank)
      add_to_family(taxon.parent_taxon, family_name)
    elsif taxon && [:Genus, :SubFamily].include?(taxon.rank) && !taxon.parent_taxon
      taxon.parent_taxon = Taxon.find_or_create_with_name(family_name, :Family)
      taxon.save!
    end
  end

  def import_specimens(file)
    CSV.foreach(file, headers: true) do |row|
      site = Site.where('ref = ?', row['Site ID']).first
      taxon = Taxon.find_or_create_with_name(row['Species'], :Genus)
      add_to_family(taxon, row['Family'])
      atts = {
        description: row['Description'],
        site_id: site.id,
        quantity: row['Quantity'],
        body_length: row['Length (mm)'],
        notes: row['Notes'],
        taxon_id: taxon ? taxon.id : nil,
        id_confidence: row['Confidence in ID (1-3)'],
        other: row['Mimic?'],
        ref: site.ref + '-' + row['Specimen ID']
      }
      Specimen.create(atts)
    end
  end

  def import_specimen_photos(dir)

    nm_re = /sp([0-9]+) ([a-z]+)\s*([0-9]?)\.jpg/
    ps = Pathname.glob(Pathname.new(dir).join('*', '*.jpg'))
    ps.uniq.each do |filename|
      parts = filename.each_filename.to_a
      site_ref = parts[-2].to_i
      nm = nm_re.match(parts[-1])
      if nm
        sp_ref = nm[1].to_i
        begin
          va = ViewAngle.new(nm[2])
        rescue
          va = nil
        end
        sp = get_specimen(site_ref, sp_ref)
        photo = Photo.create_from_io(File.open(filename), filename.to_s, 'image/jpeg', nil, false, {view_angle: va})
        sp.photos << photo
        sp.save!

        # Is there a corresponding tiff?
        tiff_ext = '.tif'
        tf = filename.sub_ext(tiff_ext)
        if tf.exist?
          photo.add_file(:tiff, tiff_ext, File.open(tf))
          photo.save!
        end
      end
    end
  end

  def import_outline_photos(dir, as_representation)
    nm_re = /([a-z]+)\.([0-9]+)-([0-9]+)-([0-9]*)\.([a-z]+)(\.jpg)/
    ps = Pathname.glob(Pathname.new(dir).join('*.jpg'))
    ps.uniq.each do |filename|
      nm = nm_re.match(filename.basename.to_s)
      if nm
        ftype = nm[1]
        site = nm[2].to_i
        spec = nm[3].to_i
        ref = nm[4]
        view = nm[5]
        ext = nm[6]
        if ftype != "src"    # Ignore source photos
          if !ref.blank?
            puts "Skipping #{site}-#{spec}-#{ref} #{view} #{ftype}"
          else
            specimen = get_specimen(site, spec)
            photos = specimen.photos.where(ViewAngle.expand_query_params(view_angle: view))
            if as_representation
              import_representation(filename, specimen, photos, view, ftype, site, spec)
            else
              import_photo(filename, specimen, photos, view, ftype, site, spec)
            end
          end
        end
      end
    end
  end

  def import_representation(filename, specimen, photos, view, ftype, site, spec)
    if photos.count == 1
      photo = photos.first
      photo.add_file("#{ftype}_outline", ext, File.open(filename))
    else
      puts "Skipping #{site}-#{spec}   #{view} #{ftype} (#{photos.count} photos)"
    end
  end
  
  def import_photo(filename, specimen, photos, view, ftype, site, spec)
    if photos.length == 1
      state = photos.first.state
      source = "Photo #{photos.first.id}"
    else
      state = nil
      source = nil
      puts "Photo state and source unknown for #{site}-#{spec}   #{view} #{ftype}"
    end
    atts = {view_angle: view,
            ptype: 'Outline',
            state: state,
            source: source,
            description: ftype}
    photo = Photo.create_from_io(File.open(filename), filename.to_s, 'image/jpeg', nil, false, atts)
    specimen.photos << photo
    specimen.save!
  end
  
  def get_specimen(site_ref, spec_ref)
    sp = Specimen.where('ref = ?', "#{site_ref}-#{spec_ref}").first
    sp = Specimen.where('ref = ?', "#{site_ref}a-#{spec_ref}").first unless sp
    sp = Specimen.where('ref = ?', "#{site_ref}b-#{spec_ref}").first unless sp
    sp
  end

  def fix_site_times
    Site.all.each do |site|
      t = site.started_at
      if t && t.year < 2000
        # Swap year and month since they were imported incorrectly
        n = Time.zone.local(2000 + t.day, t.month, t.year, t.hour, t.min)
        site.update(started_at: n)
      end
    end
  end
end

i = Import.new
#i.import_sites("C:/Users/jim_m/Google Drive/Uni/Classes/BIOL702/sites.csv")
#i.import_site_photos('C:/Jim/uni/Classes/BIOL702/Sites')
#i.import_specimens("C:/Users/jim_m/Google Drive/Uni/Classes/BIOL702/specimens.csv")
#i.import_specimen_photos('C:/Jim/uni/Classes/BIOL702/Sites')
#i.fix_site_times

i.import_outline_photos('C:/Jim/uni/Classes/BIOL760/Morphometric analysis', false)


