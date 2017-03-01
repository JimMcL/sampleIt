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

    w = QueryUtils::params_to_where({id: '[10,12,13]', other: '[10,12,13]', name: 'ruby'}, {id: true})
    assert_equal 4, w.length
    assert_equal 'id IN (?) AND other = ? AND name = ?', w[0]
    assert_equal ['10', '12', '13'], w[1]
    assert_equal '[10,12,13]', w[2]
    assert_equal 'ruby', w[3]

    w = QueryUtils::params_to_where({id: '[10,12,13]', sql: 'imageable_id in (select specimens.id from specimens join taxa on taxon_id = taxa.id where scientific_name like \'Myrmarachne%\')'}, id: true)
    p w
    assert_equal 2, w.length
    assert_equal 'id IN (?) AND imageable_id in (select specimens.id from specimens join taxa on taxon_id = taxa.id where scientific_name like \'Myrmarachne%\')', w[0]
    assert_equal ['10', '12', '13'], w[1]
  end

  test "q_to_where" do
    w = QueryUtils::q_to_where("XXX", :tab, [:id, :value], [:descr])
    assert_equal ['tab.id = ? OR tab.value = ? OR tab.descr LIKE ?', 'XXX', 'XXX', '%XXX%'], w
  end
end
