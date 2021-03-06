require "#{File.dirname(__FILE__)}/../test_helper"

class BasicRenderingTest < ActionController::IntegrationTest
  common_fixtures               
  
  warn "Defining basic rendering tests"
  test_render "card/changes/:id"        , :users=>{ :anon=>200, :joe_user=>200 }
  test_render "card/view/:id"           , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/line/:id"           , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/options/:id"        , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  # joe doesn't have permission to edit invitation_requests, so test edit as admin for now.
  # later should have cardtype-specific permissions settings
  test_render "card/edit/:id"           , :users=>{ :anon=>403, :admin=>200 }, :cardtypes=>:all
  test_render "card/new"                , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "connection/new/:id"      , :users=>{ :anon=>200, :joe_user=>200 }
  test_render "card/edit_name/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "card/edit_type/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  
=begin  

test_render "block/render_list/:id?query=recent_changes"
test_render "block/recent_list/:id?query=recent_changes"
test_render "block/search_list/:id?query=recent_changes"
test_render "block/connection_list/:id?query=recent_changes"
test_render "block/link_list/:id?query=recent_changes"

  def test_should_do_some_action
    test_action "card/update"
    test_action "card/save_draft"
    test_action "card/rollback"
    test_action "card/create"
    test_action "card/remove"
    test_action "card/comment"

    test_action "connection/create"
    test_action "connection/remove"
    
    test_action "options/update_roles"
  end 
=end
  
end
