require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  #fixtures :users
 
  def test_should_reset_password
    User.find_by_email('joe@user.com').update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal User.find_by_email('joe@user.com'), User.authenticate('joe@user.com', 'new password')
  end
  
  def test_should_create_user
    assert_difference User, :count do
      assert create_user.valid?
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference User, :count do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end



  def test_should_not_rehash_password
    User.find_by_email('joe@user.com').update_attributes!(:email => 'joe2@user.com')
    assert_equal User.find_by_email('joe2@user.com'), User.authenticate('joe2@user.com', 'joe_pass')
  end

  def test_should_authenticate_user
    assert_equal User.find_by_email('joe@user.com'), User.authenticate('joe@user.com', 'joe_pass')
  end
  
  protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', 
      :password => 'quire', :password_confirmation => 'quire',
      :invite_sender_id=>1
    }.merge(options))
  end
end
