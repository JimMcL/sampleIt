require 'test_helper'

class TaxaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @taxon = taxa(:two)
    assert_not_nil @taxon
  end

  test "should get index" do
    get taxa_url
    assert_response :success
  end

  test "should get new" do
    get new_taxon_url
    assert_response :success
  end

  test "should create taxon" do
    assert_difference('Taxon.count') do
      post taxa_url, params: { taxon: { scientific_name: 'Genus species' } }
    end

    assert_redirected_to edit_taxon_url(Taxon.last)
  end

  test "should show taxon" do
    get taxon_url(@taxon)
    assert_response :success
  end

  test "should get edit" do
    get edit_taxon_url(@taxon)
    assert_response :success
  end

  test "should update taxon" do
    patch taxon_url(@taxon), params: { taxon: { scientific_name: 'Genus species' } }
    assert_redirected_to edit_taxon_url(@taxon)
  end

  test "should destroy taxon" do
    assert_difference('Taxon.count', -1) do
      delete taxon_url(@taxon)
    end

    assert_redirected_to taxa_url
  end
end
