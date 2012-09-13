namespace :qor do
  namespace :layout do
    desc "add columns to tables"
    task :migrate => :environment do
      ActiveRecord::Migration.upgrade_table Qor::Layout::Layout.table_name do |t|
        t.string   :name
        t.string   :action_name

        t.datetime :deleted_at
        t.timestamps
      end

      ActiveRecord::Migration.upgrade_table Qor::Layout::Setting.table_name do |t|
        t.string   :name
        t.integer  :parent_id
        t.integer  :layout_id
        t.text     :value, :limit => 2147483647
        t.text     :style, :limit => 2147483647

        t.datetime :deleted_at
        t.timestamps
      end

      ActiveRecord::Migration.upgrade_table Qor::Layout::Asset.table_name do |t|
        t.string   :data_file_name
        t.string   :data_content_type
        t.string   :data_file_size
        t.string   :data_updated_at
        t.string   :data_coordinates, :limit => 1024

        t.datetime :deleted_at
        t.timestamps
      end
    end
  end
end
