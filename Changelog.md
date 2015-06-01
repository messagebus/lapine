Change Log
==========

## 2.0.0

**BREAKING CHANGES**

Queues are now declared as `durable: true`. This breaks the ability of consumers to connect to existing
queues in a way that fails silently in the `ruby-amqp` gem.

Migration strategy:

* Update gemfile to use version `1.99.0`
* All queues will need to be renamed, so that they can be declared anew with `durable: true`
* Old queues should be deleted with `delete_queues`
* Update gemfile to use version `2.0.0`

## 1.99.0 - Migration version to 2.0.0

**BREAKING CHANGES**

* `queues` are declared as `durable: true`
* `delete_queues` are declared as `durable: false`

## 1.2.2

* Add routing key to dispatcher log

## 1.2.0

* Queues can be deleted by using `delete_queues` to configuration YAML file

## 1.1.2

* Exchanges are saved using thread variables instead of fiber variables
* Move memoization of connections and exchanges to Configuration

## 1.1.1

* Fix potential thread safety issue with publisher connections to
  RabbitMQ

## 1.1.0

* Lapine consumer can be configured with middleware
  * Error handling, json decoding, and message acknowledgement now happen in middleware

## 1.0.1

* Increased verbosity of errors
* Avoid instance_variable_get in publisher
  * rename @exchange to @lapine_exchange

## 1.0.0

* Breaking Change - error handler includes metadata in method signature
