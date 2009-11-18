class CreateTickets < Sequel::Migration
  
  def up
    create_table :tickets do
      primary_key   :id			
      String        :ticket,            :null => false,		:index => true			
      DateTime      :created_on,		    :null => false,		:index => true
      DateTime      :consumed,			    :null => true			
      Integer       :ticket_id,			    :null => false			
      String        :client_hostname,	  :null => false			
      String        :iou,				        :null => false			
      String        :service,			      :null => false			
      String        :type,				      :null => false			
      String        :username,			    :null => false			
    end
  end
  
  def down
    drop_table :tickets
  end
  
end