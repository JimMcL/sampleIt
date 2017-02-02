# == Schema Information
#
# Table name: photos
#
#  id             :integer          not null, primary key
#  rating         :integer
#  filename       :text
#  imageable_type :string
#  imageable_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  thumb_path     :text
#  exif_json      :text
#

require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  test "size" do
    p1 = create_test_photo('ant1.jpg', 'image/jpeg')
    assert_equal 5184, p1.file(:photo).width
    assert_equal 3456, p1.file(:photo).height
    assert_equal [5184, 3456], p1.file(:photo).size, "Wrong jpeg file size"
    assert_nil p1.file(:tiff).size, "wrong tiff file size"
    assert_equal [300,200], p1.file(:thumb).size, "Wrong thumbnail size"  # This test is brittle since it assumes thumbnail size

    p2 = create_test_photo('ant-head.jpg', 'image/jpeg', nil, true)
    assert_equal 5184, p2.file(:photo).width
    assert_equal 3456, p2.file(:photo).height
    assert_equal [5184,3456], p2.file(:photo).size, "Wrong jpeg file size"
    assert_equal [5184,3456], p2.file(:tiff).size, "wrong tiff file size"
    assert_equal [300,200], p2.file(:thumb).size, "Wrong thumbnail size"  # This test is brittle since it assumes thumbnail size
  end
  
  test "create" do
    path = file_path('ant1.jpg')
    p1 = Photo.create_from_io(File.open(path, 'rb'), 'ant1.jpg', 'image/jpeg', nil, false)
    assert File.exists?(p1.file(:photo).abs_path), "Photo file doesn't exist: #{p1.file(:photo).abs_path}"
    assert File.exists?(p1.file(:thumb).abs_path), "Photo thumb doesn't exist: #{p1.file(:thumb).abs_path}"

    path = file_path('location.jpg')
    p2 = Photo.create_from_io(File.open(path, 'rb'), 'location.jpg', 'image/jpeg', nil, false)
    fp = p2.file(:photo).abs_path
    tp = p2.file(:thumb).abs_path
    assert File.exists?(fp), "Photo file doesn't exist: #{fp}"
    assert File.exists?(tp), "Photo thumb doesn't exist: #{tp}"
    p2.destroy
    assert_not File.exists?(fp), "Photo file wasn't deleted: #{fp}"
    assert_not File.exists?(tp), "Photo thumb wasn't deleted: #{tp}"
  end

  test "create with atts" do
    path = file_path('ant1.jpg')
    p1 = Photo.create_from_io(File.open(path, 'rb'), 'ant1.jpg', 'image/jpeg', nil, false, {view_angle: 'lateral', description: 'Description'})
    assert File.exists?(p1.file(:photo).abs_path), "Photo file doesn't exist: #{p1.file(:photo).abs_path}"
    assert File.exists?(p1.file(:thumb).abs_path), "Photo thumb doesn't exist: #{p1.file(:thumb).abs_path}"
    assert_equal 'Lateral', p1.view_angle.to_s, "Photo view angle from attributes is wrong"
    assert_equal 'Description', p1.description, "Photo description from attributes is wrong"

    p2 = Photo.create_from_io(File.open(path, 'rb'), 'ant1.jpg', 'image/jpeg', nil, false, {'view_angle' => 'dorsal', 'description' => 'Description two'})
    assert File.exists?(p2.file(:photo).abs_path), "Photo file doesn't exist: #{p2.file(:photo).abs_path}"
    assert File.exists?(p2.file(:thumb).abs_path), "Photo thumb doesn't exist: #{p2.file(:thumb).abs_path}"
    assert_equal 'Dorsal', p2.view_angle.to_s, "Photo view angle from attributes is wrong"
    assert_equal 'Description two', p2.description, "Photo description from attributes is wrong"
  end

  test "scalebar" do
    p1 = create_test_photo('ant-head.jpg', 'image/jpeg', nil, true)
  end

  test "label" do
    p1 = create_test_photo('ant-head.jpg', 'image/jpeg')
    assert_equal "#{p1.id}: photo", p1.label
    p1.description = 'Ant head'
    assert_equal "Ant head", p1.description
    assert_equal "#{p1.id}: photo, ant head", p1.label
    p1.view_angle = ViewAngle.new('lateral')
    assert_equal "#{p1.id}: photo, ant head, lateral view", p1.label
  end

  test "camera from exif" do
    p1 = create_test_photo('ant-head.jpg', 'image/jpeg')
    assert_equal "Canon EOS 7D", p1.camera
  end

  ################################################################################

  def create_test_photo(name, content_type = 'image/jpeg', exif_path = nil, scalebar = false)
    Photo.create_from_io(open_test_file(name), name, content_type, exif_path, scalebar)
  end
  
  def open_test_file(name)
    File.open(file_path(name), 'rb')
  end
  
  def file_path(name)
    File.join(self.class.fixture_path, 'files', name)
  end
end
