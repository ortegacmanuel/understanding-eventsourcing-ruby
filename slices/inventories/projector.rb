module Inventories
  module Projector
    TABLE_SQL = <<~SQL.freeze
      CREATE TABLE IF NOT EXISTS inventories (
        id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL
      );
    SQL
    
    module_function

    def create_table(conn_str)
      PG.connect(conn_str) do |conn|
        conn.exec(TABLE_SQL)
      end
    end

    def delete_table(conn_str)
      PG.connect(conn_str) do |conn|
        conn.exec('DROP TABLE IF EXISTS inventories')
      end
    end

    def process_event(conn_str, event)
      case event.event_type
      when 'InventoryChanged'
        handle_inventory_changed(conn_str, event)
      end
    end

    def handle_inventory_changed(conn_str, event)
      PG.connect(conn_str) do |conn|
        conn.exec_params(
          <<~SQL,
            INSERT INTO inventories (id, quantity)
            VALUES ($1, $2)
            ON CONFLICT (id)
            DO UPDATE
              SET quantity = EXCLUDED.quantity
          SQL
          [event.payload[:product_id], event.payload[:quantity]]
        )
      end
    end

    def rebuild(event_store, conn_str)
      PG.connect(conn_str) { |c| c.exec('DELETE FROM inventories') }
      puts '🗑️  Cleared existing inventories'

      filter = EventStoreRuby.create_filter(['InventoryChanged'])
      events = event_store.query(filter).events
      puts "📥 Found #{events.size} events to replay"

      events.each { |e| process_event(conn_str, e) }

      puts '✅ Account projections rebuilt successfully'
    end    
  end
end