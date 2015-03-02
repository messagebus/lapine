Change Log
==========

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
