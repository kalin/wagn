require File.dirname(__FILE__) + '/wagn/version'
require File.dirname(__FILE__) + '/wagn/exceptions'
require File.dirname(__FILE__) + '/ruby_ext'
require File.dirname(__FILE__) + '/rails_ext'
require File.dirname(__FILE__) + '/cardname'


COMPRESSED_JS = 'wagn_cmp.js'
JAVASCRIPT_FILES = %w{
  prototype.js
  effects.js
  application.js
  window.js
  builder.js
  calendar.js
  
  Wikiwyg.js
  Wikiwyg/Toolbar.js
  Wikiwyg/Wysiwyg.js
  Wikiwyg/Wikitext.js
  Wikiwyg/Preview.js
  Wikiwyg/Util.js
  Wikiwyg/HTML.js
  Wikiwyg/Debug.js
  
  Wagn.js
  Wagn/Card.js
  Wagn/Wikiwyg.js
  Wagn/Editor.js
  Wagn/Lister.js
  Wagn/LinkEditor.js
}

js_dir = "#{RAILS_ROOT}/public/javascripts"
Dir["#{js_dir}/Wagn/*/*.js"].collect do |file|
  JAVASCRIPT_FILES << 'Wagn/Editor/' + Pathname.new(file).basename.to_s
end