class AddDefaultTinyMceConfig < ActiveRecord::Migration
  def self.up
    unless Card['*tinyMCE']
      User.as(:admin) do
        Card::PlainText.create! :name=>"*tinyMCE", :content=> <<-eos
width: '100%',
auto_resize : true,
relative_urls: false,
theme : "advanced",
theme_advanced_buttons1 : "formatselect,bold,italic,strikethrough,"
+ "separator,blockquote,bullist,numlist,hr,separator,undo,redo,"
+ "link,code",                         
theme_advanced_buttons2 : "",                         
theme_advanced_buttons3 : "",                         
theme_advanced_path : false,                         
theme_advanced_toolbar_location : "top",  
theme_advanced_toolbar_align : "left", 
theme_advanced_resizing : true,
theme_advanced_resize_horizontal : false,                      
theme_advanced_statusbar_location : "bottom",
theme_advanced_blockformats : "p,h1,h2",
content_css : '/stylesheets/defaults.css',
extended_valid_elements : "a[name|href|target|title|onclick],"
+ "img[class|src|border=0|alt|title|hspace|vspace|width|height|"
+ "align|onmouseover|onmouseout|name],hr[class|width|size|noshade],"
+ "font[face|size|color|style],span[class|align|style]"          
eos
      end
    end 
  rescue Exception=>e
    # this will fail when using pull_wagn_db, because the data for admin user isn't present yet.  
    # it's ok to let it go in that case.
  end

  def self.down
  end
end
