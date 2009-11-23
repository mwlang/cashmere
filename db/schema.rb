Class.new(Sequel::Migration) do
  def up
    create_table(:schema_info) do
      Integer :version
    end
  end
  
  def down
    drop_table(:schema_info)
  end
end
