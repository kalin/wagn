require 'lib/util/card_builder.rb'      


def check_for_fulltext_schema
  schema_error = ("Oops! Attempt to load a schema with a broken cards table.  Rails can't properly dump and restore a schema with fulltext index data (indexed_content). " +
    "you'll need to connect to a database without these fields and rerun >rake db:schema:dump first.")
  begin 
    if Card.columns.map(&:name).include?('indexed_content')
      raise(schema_error)
    end
  rescue
    raise(schema_error)
  end
end
 
namespace :db do
  namespace :test do
    desc 'Prepare the test database and load the schema'
    task :prepare => :environment do   
      check_for_fulltext_schema        
      if defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?
        Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone" }[ActiveRecord::Base.schema_format]].invoke
      end 
      puts ">>loading test fixtures"
      puts `rake db:fixtures:load RAILS_ENV=test`
    end
  end
end

#require 'rake'
#require 'rake/testtask'
#require 'rake/rdoctask'
#require 'tasks/rails'
                  

                    
namespace :db do
  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end  
      Rake::Task['wagn:prepare_fulltext'].invoke
    end
  end
end
        
namespace 'wagn' do
  desc "create sample data for testing"
  task :populate_template_database => :environment do   
    # setup test data here
    # admin and hoozebot are created in the migration
    # These are the cards that are present in basic installation before test data is added:
    #
    #        name         |   type   
    #---------------------+----------
    # Wagn                | Basic
    # Basic               | Cardtype
    # User                | Cardtype
    # Cardtype            | Cardtype
    # Role                | Cardtype
    # InvitationRequest   | Cardtype
    # Anyone              | Role    
    # Administrative User | Role
    # Anyone signed in    | Role
    # Wagn Bot            | User
    # Admin               | User
   
    ::User.as(:admin) do 
      # the original admin user will also be present for new installs, so we don't want
      # that password discoverable.  reset password here so we know it for the tests.
      admin = User.find_by_login('admin')
      admin.update_attribute('crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c')

      #fail(" user permissions #{::Card::User.new.cardtype.permissions}" )
      # generic, shared user
      joe_user = ::User.create! :login=>"joe_user",:email=>'joe@user.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass', :invite_sender=>User.find_by_login('admin')
      joe_card = Card::User.create! :name=>"Joe User", :extension=>joe_user, :content => "I'm number two"    

      bt = Card.find_by_name 'Basic+*tform'
      fail "oh god #{bt.permissions.inspect}" if bt.permissions.empty?
       
      # generic, shared attribute card
      color = Card::Basic.create! :name=>"color"
      basic = Card::Basic.create! :name=>"Basic Card"  
                                  
      # data for testing users and invitation requests 
      System.invite_request_alert_email = nil
      ron_request = Card::InvitationRequest.create! :name=>"Ron Request", :email=>"ron@request.com"  
      no_count = Card::User.create! :name=>"No Count", :content=>"I got not account"

      # CREATE A CARD OF EACH TYPE
      user_user = ::User.create! :login=>"sample_user",:email=>'sample@user.com', :status => 'active', :password=>'sample_pass', :password_confirmation=>'sample_pass', :invite_sender=>User.find_by_login('admin')
      user_card = Card::User.create! :name=>"Sample User", :extension=>user_user    

      request_card = Card::InvitationRequest.create! :name=>"Sample InvitationRequest", :email=>"invitation@request.com"  
      Cardtype.find(:all).each do |ct|
        next if ['User','InvitationRequest'].include? ct.codename
        Card.create! :type=>ct.codename, :name=>"Sample #{ct.codename}"
      end


      # data for role_test.rb
      u1 = ::User.create! :login=>"u1",:email=>'u1@user.com', :status => 'active', :password=>'u1_pass', :password_confirmation=>'u1_pass', :invite_sender=>User.find_by_login('admin')
      u2 = ::User.create! :login=>"u2",:email=>'u2@user.com', :status => 'active', :password=>'u2_pass', :password_confirmation=>'u2_pass', :invite_sender=>User.find_by_login('admin')
      u3 = ::User.create! :login=>"u3",:email=>'u3@user.com', :status => 'active', :password=>'u3_pass', :password_confirmation=>'u3_pass', :invite_sender=>User.find_by_login('admin')
      
      Card::User.create!(:name=>"u1", :extension=>u1)
      Card::User.create!(:name=>"u2", :extension=>u2)
      Card::User.create!(:name=>"u3", :extension=>u3)

      r1 = Card::Role.create!( :name=>'r1' ).extension
      r2 = Card::Role.create!( :name=>'r2' ).extension
      r3 = Card::Role.create!( :name=>'r3' ).extension
      r4 = Card::Role.create!( :name=>'r4' ).extension
  
      r1.users = [ u1, u2, u3 ]
      r2.users = [ u1, u2 ]
      r3.users = [ u1 ]
      r4.users = [ u3, u2 ]
  
      c1 = Card.create! :name=>'c1'
      c2 = Card.create! :name=>'c2'
      c3 = Card.create! :name=>'c3'   

      # cards for rename_test
      # FIXME: could probably refactor these..
      z = Card.create! :name=>"Z", :content=>"I'm here to be referenced to"
      a = Card.create! :name=>"A", :content=>"Alpha [[Z]]"
      b = Card.create! :name=>"B", :content=>"Beta {{Z}}"        
      t = Card.create! :name=>"T", :content=>"Theta"
      x = Card.create! :name=>"X", :content=>"[[A]] [[A+B]] [[T]]"
      y = Card.create! :name=>"Y", :content=>"{{B}} {{A+B}} {{A}} {{T}}"
      ab = a.connect(b, "AlphaBeta")
    
      c12345 = Card.create:name=>"One+Two+Three"
      c12345 = Card.create:name=>"Four+One+Five"

      # for wql & permissions 
      %w{ A+C A+D A+E C+A D+A F+A A+B+C }.each do |name| Card.create! :name=>name  end 
    
      Card::Cardtype.create! :name=>"Cardtype A", :codename=>"CardtypeA"
      bt = Card::Cardtype.create! :name=>"Cardtype B", :codename=>"CardtypeB"
      Card::Cardtype.create! :name=>"Cardtype C", :codename=>"CardtypeC"
      Card::Cardtype.create! :name=>"Cardtype D", :codename=>"CardtypeD"
      Card::Cardtype.create! :name=>"Cardtype E", :codename=>"CardtypeE"
      Card::Cardtype.create! :name=>"Cardtype F", :codename=>"CardtypeF"

      Card::Basic.create! :name=>'basicname', :content=>'basiccontent'
      Card::CardtypeA.create! :name=>"type-a-card", :content=>"type_a_content"
      Card::CardtypeB.create! :name=>"type-b-card", :content=>"type_b_content"
      Card::CardtypeC.create! :name=>"type-c-card", :content=>"type_c_content"
      Card::CardtypeD.create! :name=>"type-d-card", :content=>"type_d_content"
      Card::CardtypeE.create! :name=>"type-e-card", :content=>"type_e_content"
      Card::CardtypeF.create! :name=>"type-f-card", :content=>"type_f_content"
  
      bt.permit(:create, Role['r1']); bt.save!  # set it so that Joe User can't create this type
      c = Card.create! :name=>'revtest', :content=>'first'
      c.update_attributes! :content=>'second'
      c.update_attributes! :content=>'third'
      #Card::Cardtype.create! :name=>'*priority'      
  
      # for template stuff
      Card::Cardtype.create! :name=> "UserForm"
      Card.create! :name=>"UserForm+*tform", :content=>"{{+name}} {{+age}} {{+description}}",
        :extension_type=>"HardTemplate"
      #Card::UserForm.create! :name=>"JoeForm"      
      
      
      User.as(:joe_user) {  Card.create!( :name=>"JoeLater", :content=>"test") }
      User.as(:joe_user) {  Card.create!( :name=>"JoeNow", :content=>"test") }
      User.as(:admin) {  Card.create!(:name=>"AdminNow", :content=>"test") }
      
    end   

    #::User.as( ::User.find_by_login('anonymous'))) do 
    #  Card::InvitationRequest
    #end
  end


  desc "recreate test fixtures from fresh db"
  task :generate_fixtures => :environment do  

    if System.enable_postgres_fulltext
      raise("Oops!  you need to disable postgres_fulltext in wagn.rb before generating fixtures")
    end
         
    abcs = ActiveRecord::Base.configurations    
    config = RAILS_ENV || 'development'  
    olddb = abcs[config]["database"]
    abcs[config]["database"] = "wagn_test_template"

    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    

    puts ">>migrating template database"
    System.site_title = 'Wagn'
    Rake::Task['db:migrate'].invoke  

  #=begin  
    begin
      set_database 'wagn_test_template'
  
      # I spent waay to long trying to do this in a less hacky way--  
      # Basically initial database setup/migration breaks your models and you really 
      # need to start rails over to get things going again I tried ActiveRecord::Base.reset_subclasses etc. to no avail. -LWH
      puts ">>populating test data"
      puts `rake wagn:populate_template_database --trace`      
      puts ">>extracting to fixtures"
      puts `rake wagn:extract_fixtures`
      set_database olddb 
    rescue Exception=>e
      set_database olddb 
      raise e
    end  
    puts ">>preparing test database"
    # go ahead and load the fixtures into the test database
    Rake::Task['db:test:prepare'].invoke
  #=end
  end

  desc "dump current db to test fixtures"
  task :extract_fixtures => :environment do
    sql = "SELECT * FROM %s"
    skip_tables = ["schema_info","schema_migrations","sessions"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end    
end
        
def set_database( db )
  y = YAML.load_file("#{RAILS_ROOT}/config/database.yml")
  y["development"]["database"] = db
  y["production"]["database"] = db
  File.open( "#{RAILS_ROOT}/config/database.yml", 'w' ) do |out|
    YAML.dump( y, out )
  end
end
#end