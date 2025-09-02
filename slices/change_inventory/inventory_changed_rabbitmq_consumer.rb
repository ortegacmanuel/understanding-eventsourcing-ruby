require 'bunny'
require 'json'
require 'time'
require_relative 'change_inventory'

module ChangeInventory
  class InventoryChangedRabbitmqConsumer
    def initialize(amqp_url:, exchange:, queue:, routing_key:, event_store:)
      @amqp_url    = amqp_url
      @exchange    = exchange
      @queue       = queue
      @routing_key = routing_key
      @stop        = false
      @event_store = event_store
    end

    def start!
      @thread = Thread.new { run_loop }
    end

    def stop!
      @stop = true
      begin
        @channel&.close
        @conn&.close
      rescue => e
        puts "Rabbit close failed: #{e.class}: #{e.message}"
      end
      @thread&.join(2)
    end

    private

    def run_loop
      @conn = Bunny.new(@amqp_url)
      @conn.start
      @channel = @conn.create_channel
      @channel.prefetch(20)

      ex = @channel.topic(@exchange, durable: true)
      q  = @channel.queue(@queue, durable: true)
      q.bind(ex, routing_key: @routing_key)

      puts "Listening on queue=#{@queue} exchange=#{@exchange} rk=#{@routing_key}"

      q.subscribe(manual_ack: true, block: true) do |delivery_info, _props, payload|
        break if @stop
        handle_message(delivery_info, payload)
      end
    rescue Interrupt
      # normal shutdown
    rescue => e
      puts "Listener crashed: #{e.class}: #{e.message}"
      puts e.backtrace.join("\n")
      sleep 1
      retry unless @stop
    ensure
      begin
        @channel&.close
        @conn&.close
      rescue
      end
    end

    def handle_message(delivery_info, payload)
      evt = JSON.parse(payload)
      product_id    = evt.fetch('product_id')
      quantity        = evt.fetch('quantity')

      command = ChangeInventoryCommand.new(
        product_id: product_id,
        quantity: quantity
      )
      new_events = ChangeInventoryCommandHandler.call([], command)
      @event_store.append(new_events)

      @channel.ack(delivery_info.delivery_tag)
    rescue JSON::ParserError, KeyError => e
      # permanent bad message → send to DLQ
      @channel.nack(delivery_info.delivery_tag, false, false)
    rescue => e
      # transient → send to retry queue (dead-letter)
      @channel.nack(delivery_info.delivery_tag, false, false)
    end
  end
end