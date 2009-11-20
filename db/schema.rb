Class.new(Sequel::Migration) do
  def up
    create_table(:schema_info) do
      Integer :version
    end
    
    create_table(:tickets, :ignore_index_errors=>true) do
      primary_key :id
      String :ticket, :null=>false
      DateTime :created_on, :null=>false
      DateTime :consumed
      Integer :ticket_id, :null=>false
      String :client_hostname, :null=>false
      String :iou, :null=>false
      String :service, :null=>false
      String :type, :null=>false
      String :username, :null=>false
      
      index [:created_on]
      index [:ticket]
    end
  end
  
  def down
    drop_table(:schema_info, :tickets)
  end
end
