require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest


   test "can see the welcome page" do
     get "/"
     assert_select "h1", "Welcome"
   end

   test "specimens index" do
     get "/specimens"
     assert_select "h1", "Specimens"
   end

   test "sites index" do
     get "/sites"
     assert_select "h1", "Sites"
   end

   test "taxa index" do
     get "/taxa"
     assert_select "h1", "Taxa"
   end

end
