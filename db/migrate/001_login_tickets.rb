class CreateLoginTickets < Sequel::Migration
  
  def up
    create_table :login_tickets do
      primary_key :id
      String      :ticket,          :null => false,   :index => true
      DateTime    :created_on,      :null => false
      DateTime    :consumed,        :null => true
      String      :client_hostname, :null => false
    end

    create_table :service_tickets do
      primary_key :id
      String      :ticket,          :null => false,   :index => true
      DateTime    :created_on,      :null => false
      DateTime    :consumed,        :null => true
      String      :client_hostname, :null => false
      String      :service,         :null => false
      String      :username,        :null => false
      String      :type,            :null => false
      Integer     :pgt_id,          :null => true
    end

    create_table :ticket_granting_tickets do
      primary_key :id
      String      :ticket,          :null => false,   :index => true
      DateTime    :created_on,      :null => false
      DateTime    :consumed,        :null => true
      String      :client_hostname, :null => false
    end

    create_table :proxy_granting_tickets do
      primary_key :id
      String      :ticket,              :null => false,   :index => true
      DateTime    :created_on,          :null => false
      String      :client_hostname,     :null => false
      String      :iou,                 :null => false
      Integer     :service_ticket_id,   :null => false
    end
  end
  
  def down
    drop_table :login_tickets
    drop_table :service_tickets
    drop_table :ticket_granting_tickets
    drop_table :proxy_granting_tickets
  end
  
end

