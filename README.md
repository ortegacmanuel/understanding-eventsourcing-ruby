
# 🧑‍💻 understanding-eventsourcing-ruby

An implementation of the Event Model from the book Understanding Eventsourcing from Martin Dilger with Ruby ([Sinatra](https://sinatrarb.com/) + [EventStoreRuby](https://github.com/gazpachoteam/eventstore-ruby))

See the book here: https://leanpub.com/eventmodeling-and-eventsourcing
The repository with the implementation example: https://github.com/dilgerma/eventsourcing-book

# 🧩 Slice Architecture

The application is split into small, independent *slices*.  Each slice lives in its
own directory under `slices/` and exposes a single public entry-point file named
`slice.rb`.  That file:

1. `require_relative`-s the slice’s internal code (API, projector, listener…).
2. `extend Slice` – mixes in the minimal framework.
3. Calls `on_boot { |**deps| … }` to wire the slice into the app.

```ruby
# slices/my_feature/slice.rb

require_relative '../../lib/slice'
require_relative 'api'

module MyFeature
  extend Slice

  on_boot do |event_store:, app:, conn_str:, register:, resolve:|
    # Mount HTTP endpoints
    API.set :event_store, event_store
    app.use API

    # Expose an object that other slices might want
    register.call(:my_feature_api, API)
  end
end
```

## Automatic discovery

`require_relative 'slices'` (see `app.rb`) loads **every** `*/slice.rb` file
automatically; developers don’t touch a central list when adding a new slice.

## Boot order overrides

Most of the time order doesn’t matter, but if a slice *must* boot first you can
prepend its module constant to `Slices::BOOT_ORDER` **before** calling
`Slices.boot_all`:

```ruby
# app.rb (or an initializer)

Slices::BOOT_ORDER << Inventories   # ensure tables exist early
Slices::BOOT_ORDER << PaymentsSlice # charges cards before emails

Slices.boot_all(
  event_store: Application::Container.event_store,
  app: WebApp,
  conn_str: ENV.fetch('DATABASE_URL')
)
```

Any slice not listed in `BOOT_ORDER` is appended automatically, so you only care
about the special cases.

## Sharing objects between slices

`Slices.boot_all` always provides two lambdas to every slice:

* `register.(key, value)` – publish something (an API object, service, repo…)
* `resolve.(key)` – retrieve it later

Example: Payments exposes its public API; Notifications resolves it without
knowing how Payments is implemented.

```ruby
# slices/payments/slice.rb
register.call(:payments_api, Payments::PublicAPI.new)

# slices/notifications/slice.rb
payments = resolve.call(:payments_api)
Notifier.configure(payments)
```

This keeps slices decoupled while remaining explicit and testable.

## Creating a new slice (TL;DR)

1. `mkdir slices/search`  ➜  `touch slices/search/slice.rb`
2. Inside `slice.rb`:
   ```ruby
   require_relative '../../lib/slice'
   module Search
     extend Slice
     on_boot { |app:, **_| app.use API }
   end
   ```
3. Add whatever internal files you need (`api.rb`, `projector.rb`, …).
4. Run the app – it loads automatically.

Happy slicing! 🎉 

## CartProducts read model

Rebuild projection:
```bash
bundle exec rake projections:rebuild_cart_products
```

Query via HTTP (assuming `CartsWithProducts::API` mounted):
```bash
curl http://localhost:9292/carts/<cart_id>/products