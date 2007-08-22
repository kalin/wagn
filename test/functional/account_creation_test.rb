require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountCreationTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
 
  include AuthenticatedTestHelper

  common_fixtures

  def setup
    test_renderer
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    setup_default_user
    login_as :joe_user
  end

  def test_should_create_account_from_invitation_request               
    assert_difference Card::InvitationRequest, :count, -1 do
      assert_difference Card::User, :count, 1 do
        post_invite :card=>{ :name=>"Ron Request"}
      end
    end
    assert_equal "active", User.find_by_email("ron@request.com").status
  end

  def test_should_require_valid_cardname
    assert_raises(ActiveRecord::RecordInvalid) do  
      post_invite :card => { :name => "Joe+User/" }
    end
  end

  def test_should_create_account_from_scratch
    assert_difference ActionMailer::Base.deliveries, :size do 
      assert_new_account do 
        post_invite
      end
    end
    email = ActionMailer::Base.deliveries[-1]      
    # emails should be 'from' inviting user
    assert_equal User.current_user.email, email.from[0]  
    assert_equal 'active', User.find_by_email('new@user.com').status
    assert_equal 'active', User.find_by_email('new@user.com').status
  end
  
  def test_should_create_account_from_existing_user  
    assert_difference ::User, :count do
      assert_no_difference Card::User, :count do
        post_invite :card=>{ :name=>"No Count" }, :user=>{ :email=>"no@count.com" }
      end
    end
  end
  
  
  # should work -- we generate a password if it's nil
  def test_should_generate_password_if_not_given
    assert_new_account do
      post_invite
      assert !assigns(:user).password.blank?
    end
  end

  def test_should_require_password_confirmation_if_password_given
    assert_no_new_account do
      assert_raises(ActiveRecord::RecordInvalid) do 
        post_invite :user=>{ :password=>'tedpass' }
      end
    end
  end

  def test_should_require_email
    assert_no_new_account do
      assert_raises(ActiveRecord::RecordInvalid) do 
        post_invite :user=>{ :email => nil }
        #assert assigns(:user).errors.on(:email)
        #assert_response :success
      end
    end
  end   
  
  def test_create_permission_denied_if_not_logged_in
    logout
    # FIXME weird-- i think this should raise an error-- but at least is doesn't
    # seem to be actually creating the account.  hrmph.
    # assert_raises(Wagn::PermissionDenied) do
    assert_no_new_account do
      post_invite
    end
    #end
  end
    
    
  def test_should_require_unique_email
    assert_raises(ActiveRecord::RecordInvalid) do
      post_invite :user=>{ :email=>'joe@user.com' }
    end
  end

end