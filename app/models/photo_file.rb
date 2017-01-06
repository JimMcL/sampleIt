# == Schema Information
#
# Table name: photo_files
#
#  id         :integer          not null, primary key
#  ftype      :string           not null
#  path       :text             not null
#  photo_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  width      :integer
#  height     :integer
#
# Indexes
#
#  index_photo_files_on_photo_id_and_ftype  (photo_id,ftype) UNIQUE
#

# Path is a relative path - relative to IMAGES_ROOT which means
# it can be used as the source for a call to image_tag
class PhotoFile < ApplicationRecord
  belongs_to :photo
  validates :ftype, presence: true;
  validates :path, presence: true;

  # Callbacks
  after_commit :delete_file_from_disk, on: [:destroy]


  IMAGES_ROOT = Rails.root.join('public', 'images')

  # Override ftype getter to return a symbol
   def ftype
     ft = self.attributes['ftype']
     ft ? ft.to_sym : ft
   end

  def abs_path
    IMAGES_ROOT.join(path)
  end

  def copy_content(io)
    IO.copy_stream(io, abs_path)
  end

  def delete_file_from_disk
    File.delete(abs_path) if File.exist?(abs_path)
  end

  def update_size
    sz = ImageUtils::get_dimensions(abs_path)
    self.width = sz[0]
    self.height = sz[1]
  end

  def update_size!
    update_size
    save!
  end

  # Returns "<width>x<height>", scaled
  def size(scale = 1)
    "#{(width * scale).round}x#{(height * scale).round}" if width && height
  end

end
