Lapine
======

Speak to RabbitMQ. This gem serves as a wrapper for publishing messages
to RabbitMQ via the Bunny gem.


## Configuration

Initialization can be done inline in a daemon, or if used in Rails
an initializer should be made at `config/initializers/lapine.rb`

Register a connection. This connection should be given a name, and
a hash of connection options that will be passed through to Bunny.

```ruby
Lapine.add_connection 'my-connection', {
  host: 'my-rabbitmq.mine.com',
  port: 5672,
  user: 'rabbit',
  password: 'meow'
}
```

Then register an exchange.

```ruby
Lapine.add_exchange 'efrafa', 
  durable: true, 
  connection: 'my-connection',  # required
  type: 'topic'              # required
```

## Usage

Define a class that configures which `exchange` is uses. This class
must define `#to_hash`

```ruby
require 'lapine'

class Worker
  include Lapine::Publisher
  
  exchange 'efrafa'
  
  def initialize(action)
    @action = action
  end
  
  def to_hash
    {
      'action' => @action
    }
  end
end
```

This class can be used to publish messages onto its exchange:

```ruby
Worker.new('dig').publish
```

Publishing can take a routing key for topic exchanges:

```ruby
Worker.new('dig').publish('rabbits.drones')
```

Note that the `#initialize` method and the contents of `#to_hash`
are arbitrary.


## But... WHY

* This should be dead simple, but everything else was either too
  complex or assumed very specific configurations different from what
  we want.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/lapine/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
