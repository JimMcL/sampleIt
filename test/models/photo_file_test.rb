require 'test_helper'

class PhotoFileTest < ActiveSupport::TestCase
  test "types" do
    ft = AttachmentFileType.get(:photo)
    ft = AttachmentFileType.get(:video)
    ft = AttachmentFileType.get(:tiff)
  end
end
