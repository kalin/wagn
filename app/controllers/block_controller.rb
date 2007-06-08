class BlockController < ApplicationController
  layout 'application'
  helper :wagn, :card
  
  before_filter :load_cards_from_params
                 
  def recent; 
    @title = 'Recent Changes'  
  end
  def search; 
    @title = %{Search results for "#{params[:keyword]}"}
  end
     
  def render_list( render_args )   
    render_args[:locals].merge!( :cards=>@cards, :duplicates=>@duplicates )
    respond_to do |format|    
      format.html { render render_args }
      format.json { render_args[:locals][:context] = "sidebar"; render_jsonp render_args }
    end
  end
  
  def recent_list
    render_list :partial=>'block/recent_changes', :locals=>{
      :context=>"searchresult", 
      :title=>"Recent Changes",
    } 
  end

  def search_list
    render_list :partial=>'block/card_list', :locals=>{
      :context => "searchresult", 
      :title=>%{Search results for "#{params[:keyword]}"}
    }
  end

  def connection_list
    render_list :partial=>'block/card_list', :locals => {
      :context => 'connections'
    }                                     
  end  
  
  def link_list
    render_list :partial=>'block/link_list', :locals=>{
      :card => @card
    }
  end
  
end