class CreateTickets < Sequel::Migration
  
  def up
    create_table :tickets do
      primary_key   :id			
      String        :ticket,            :null => false,		:index => true			
      DateTime      :created_at,		    :null => false,		:index => true
      Integer       :ticket_id,			    :null => true			
      String        :hostname,	        :null => true			
      String        :service,			      :null => true			
      String        :username,			    :null => true			
    end
  end
  
  def down
    drop_table :tickets
  end
  
end