require File.dirname(__FILE__) + '/../../spec_helper'

# FIXME this shouldn't be here
describe Card::Cardtype, ".create with :codename" do
  before do
    User.as :joe_user
  end
  it "should work" do
    Card::Cardtype.create!(:name=>"Foo Type", :codename=>"foo").type.should=='Cardtype'
  end
end            

describe Card, ".create_these" do
  it 'should create basic cards given name and content' do 
    Card.create_these "testing_name" => "testing_content" 
    Card["testing_name"].content.should == "testing_content"
  end

  it 'should return the cards it creates' do 
    c = Card.create_these "testing_name" => "testing_content" 
    c.first.content.should == "testing_content"
  end
  
  it 'should create cards of a given type' do
    Card.create_these "Cardtype:Footype" => "" 
    Card["Footype"].type.should == "Cardtype"
  end   
  
  it 'should take a hash of type:name=>content pairs' do
    Card.create_these 'AA'=>'aa', 'BB'=>'bb'      
    Card['AA'].content.should == 'aa'
    Card['BB'].content.should == 'bb'
  end
  
  it 'should take an array of {type:name=>content},{type:name=>content} hashes' do
    Card.create_these( {'AA'=>'aa'}, {'AA+BB'=>'ab'} )
    Card['AA'].content.should == 'aa'
    Card['AA+BB'].content.should == 'ab'
  end
end

 


describe Card, "created by Card.new " do
  before(:each) do     
    User.as :admin
    @c = Card::Basic.new :name=>"New Card", :content=>"Great Content"
  end
  
  it "should have attribute_tracking updates" do
    ActiveRecord::AttributeTracking::Updates.should === @c.updates
  end
  
  it "should return original value for name" do
    @c.name.should == 'New Card'
  end
  
  it "should track changes to name" do
    @c.name = 'Old Card'
    @c.name.should == 'Old Card'
  end
end
                  


describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    User.as :admin
    @b = Card.create :name=>"New Card", :content=>"Great Content"
    @c = Card.find(@b.id)
  end

  it "should not have errors"        do @b.errors.size.should == 0        end
  it "should have the right class"   do @c.class.should    == Card::Basic end
  it "should have the right key"     do @c.key.should      == "new_card"  end
  it "should have the right name"    do @c.name.should     == "New Card"  end
  it "should have the right content" do @c.content.should  == "Great Content" end

  it "should have a revision with the right content" do
    @c.current_revision.content == "Great Content"
  end

  it "should be findable by name" do
    Card.find_by_name("New Card").class.should == Card::Basic
  end  
end

describe Card, "create junction" do
  before(:each) do
    User.as :joe_user
    @c = Card.create! :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    @c.errors.size.should == 0
  end

  it "should create junction card" do
    Card.find_by_name("Peach+Pear").class.should == Card::Basic
  end

  it "should create trunk card" do
    Card.find_by_name("Peach").class.should == Card::Basic
  end

  it "should create tag card" do
    Card.find_by_name("Pear").class.should == Card::Basic
  end
end
       




describe Card, "types" do
  before do
    User.as :admin 
    # NOTE: it looks like these tests aren't DRY- but you can pull the cardtype creation up here because:
    #  creating cardtypes creates constants in the namespace, and those aren't removed 
    #  when the db is rolled back, so you're not starting in the original state.
    #  during use of the application the behavior probably won't create a problem, so we test around it here.
  end
  
  it "should accept cardtype name and casespace variant as type" do
    ct = Card::Cardtype.create! :name=>"AFoo"
    ct.update_attributes! :name=>"FooRenamed"
    Card.create!(:type=>"FooRenamed",:name=>"testy").class.should == Card::AFoo
    Card.create!(:type=>"foo_renamed",:name=>"so testy").class.should == Card::AFoo
  end

  it "should accept classname as type" do
    ct = Card::Cardtype.create! :name=>"BFoo"
    ct.update_attributes! :name=>"BFooRenamed"
    Card.create!(:type=>"BFoo",:name=>"testy").class.should == Card::BFoo
  end
  
  it "should accept cardtype name first when both are present" do
    ct = Card::Cardtype.create! :name=>"CFoo"
    ct.update_attributes! :name=>"CFooRenamed"
    Card::Cardtype.create! :name=>"CFoo"
    Card.create!(:type=>"CFoo",:name=>"testy").class.should == Card::CFoo1
  end
  
  it "should raise a validation error if a bogus type is given" do
    ct = Card::Cardtype.create! :name=>"DFoo"
    c = Card.new(:type=>"$d_foo#adfa",:name=>"more testy")
    c.valid?.should be_false
    c.errors_on(:type).should_not be_empty
  end
  
end
             