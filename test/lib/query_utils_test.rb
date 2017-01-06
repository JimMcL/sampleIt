require 'test_helper'

class QueryUtilsTest < ActiveSupport::TestCase
  test "tokenise" do
    t = QueryUtils::tokenise('one two "three and four"')
    assert_equal 3, t.length
    assert_equal 'one', t[0]
    assert_equal 'two', t[1]
    assert_equal 'three and four', t[2]

  end

  test "params_to_where" do
    w = QueryUtils::params_to_where({id: 10, name: 'ruby'})
    assert_equal 3, w.length
    assert_equal 'id = ? AND name = ?', w[0]
    assert_equal 10, w[1]
    assert_equal 'ruby', w[2]
  end
end
