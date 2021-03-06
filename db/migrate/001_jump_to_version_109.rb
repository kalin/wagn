require_dependency 'db/card_creator.rb'

class JumpToVersion109 < ActiveRecord::Migration
  def self.up       
    # the jump hack plays havoc with regular migrations, so only include it when we're jumping
    require 'lib/schema_version_jump_hack'
    if Rails::VERSION::MAJOR >= 2 && Rails::VERSION::MINOR >= 1         
      sm_table = ActiveRecord::Migrator.schema_migrations_table_name
      ActiveRecord::Base.connection.insert("INSERT INTO #{sm_table} (version) VALUES ('#{BOOTSTRAP_VERSION}')")
    end
    
    create_table "cards", :force => true do |t|
      t.column "trunk_id",            :integer
      t.column "created_at",          :datetime,                    :null => false
      t.column "value",               :string
      t.column "updated_at",          :datetime,                    :null => false
      t.column "current_revision_id", :integer
      t.column "name",                :string
      t.column "type",                :string,                      :null => false
      t.column "extension_id",        :integer
      t.column "extension_type",      :string
      t.column "sealed",              :boolean,  :default => false
      t.column "created_by",          :integer
      t.column "updated_by",          :integer
      t.column "priority",            :integer,  :default => 0
      t.column "plus_sidebar",        :boolean,  :default => false
      t.column "reader_id",           :integer
      t.column "writer_id",           :integer
      t.column "reader_type",         :string
      t.column "writer_type",         :string
      t.column "old_tag_id",          :integer
      t.column "tag_id",              :integer
      t.column "key",                 :string
      t.column "trash",               :boolean,  :default => false, :null => false
      t.column "appender_type",       :string
      t.column "appender_id",         :integer
    end

    add_index "cards", ["extension_id", "extension_type"], :name => "cards_extension_index"
    add_index "cards", ["key"], :name => "cards_key_uniq", :unique => true
    add_index "cards", ["name"], :name => "cards_name_index"
    add_index "cards", ["trunk_id"], :name => "index_cards_on_trunk_id"
    add_index "cards", ["tag_id"], :name => "index_cards_on_tag_id"

    create_table "cardtypes", :force => true do |t|
      t.column "class_name", :string
      t.column "system",     :boolean
    end

    add_index "cardtypes", ["class_name"], :name => "cardtypes_class_name_uniq", :unique => true
    
    create_table "permissions", :force => true do |t|
      t.column "card_id",    :integer
      t.column "task",       :string
      t.column "party_type", :string
      t.column "party_id",   :integer
    end

    add_index "permissions", ["card_id", "task"], :name => "permissions_task_card_id_uniq", :unique => true

    create_table "revisions", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "card_id",    :integer,  :null => false
      t.column "created_by", :integer,  :null => false
      t.column "content",    :text,     :null => false
    end

    create_table "roles", :force => true do |t|
      t.column "codename", :string
      t.column "tasks",    :string
    end

    create_table "roles_users", :id => false, :force => true do |t|
      t.column "role_id", :integer, :null => false
      t.column "user_id", :integer, :null => false
    end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

    create_table :settings do |t|
      t.column :codename, :string
    end

    create_table "system", :force => true do |t|
      t.column "name", :string, :default => ""
    end

    create_table "users", :force => true do |t|
      t.column "login",               :string,   :limit => 40
      t.column "email",               :string,   :limit => 100
      t.column "crypted_password",    :string,   :limit => 40
      t.column "salt",                :string,   :limit => 42
      t.column "created_at",          :datetime
      t.column "updated_at",          :datetime
      t.column "password_reset_code", :string,   :limit => 40
      t.column "blocked",             :boolean,                 :default => false,     :null => false
      t.column "cards_per_page",      :integer,                 :default => 25,        :null => false
      t.column "hide_duplicates",     :boolean,                 :default => true,      :null => false
      t.column "status",              :string,                  :default => "request"
      t.column "invite_sender_id",    :integer
    end

    create_table "wiki_references", :force => true do |t|
      t.column "created_at",         :datetime,                              :null => false
      t.column "updated_at",         :datetime,                              :null => false
      t.column "card_id",            :integer,               :default => 0,  :null => false
      t.column "referenced_name",    :string,                :default => "", :null => false
      t.column "referenced_card_id", :integer
      t.column "link_type",          :string,   :limit => 1, :default => "", :null => false
    end  
    
    # this env switch used by import scripts-- 
    #  create structure with no data; then load data dumped from another wagn
    if ENV['WAGN_SKIP_BOOTSTRAP_DATA']
      puts "Skipping data load"
    else        
      puts ">> loading bootstrap_data"  
      #`rake wagn:load_bootstrap_data`  -- this doesn't work under windows
      Rake::Task['wagn:load_bootstrap_data'].invoke
    end
  end
  
  
  def self.down
    raise IrreversibleMigration
  end
      
end
