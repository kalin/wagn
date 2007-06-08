require_dependency "acts_as_card_extension"

class Role < ActiveRecord::Base
  acts_as_card_extension
  has_and_belongs_to_many :users
  @@anonymous_user = User.new(:login=>'anonymous')  

  alias_method :users_without_special_roles, :users
  def users_with_special_roles
    if codename=='auth'
      User.active_users
    elsif codename=='anon'
      User.active_users + [@@anonymous_user]
    else
      users_without_special_roles
    end
  end
  alias_method :users, :users_with_special_roles
  
  def task_list
    (self.tasks || '').split ","
  end
  
  def cardname
    self.card.name
  end
  
  def subset_of?( role )
    users.detect {|u| !role.users.include?(u) }.nil?
  end
  
  def subset_roles
    Role.find(:all).select{|r| r.subset_of?(self) }
  end
  
  def superset_roles
    Role.find(:all).select{|r| self.subset_of?(r) }
  end
  
  class << self
    def find_configurables
      @roles = Role.find :all, :conditions=>"codename <> 'admin'"
    end
  end
  
  
end