# == Schema Information
#
# Table name: specimens
#
#  id          :integer          not null, primary key
#  description :text
#  site_id     :integer
#  quantity    :integer
#  body_length :float
#  notes       :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  taxon_id    :integer
#

require 'test_helper'

class SpecimenTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
