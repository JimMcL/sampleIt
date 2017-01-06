require 'test_helper'

class PhotoFileTest < ActiveSupport::TestCase
  test "types" do
    ft = PhotoFileType.get(:photo)
  end
end
