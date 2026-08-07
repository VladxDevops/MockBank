# Kafka - Hello World Example

This document outlines a very basic example of publishing and consuming messages on a Kafka topic, demonstrating the core concepts.

## Topic Setup
The topic will be named 'hello-world'.

## Publishing (Producer)
A producer sends messages to a topic.  Imagine this as an event being emitted by one service.

## Consuming (Consumer)
A consumer receives and processes messages from a topic. This is another service reacting to the event.

**Conceptual Flow:**
1. A 'producer' application publishes the message 'Hello World!' to the 'hello-world' topic.
2. A 'consumer' application subscribes to the 'hello-world' topic and receives the message.
3. The consumer processes the message (in this case, simply printing it to the console).

**Implementation Notes (Illustrative – not a complete code example):**
*   Producer: Would use a Kafka client library to connect to the Kafka broker and send the 'Hello World!' message.
*   Consumer: Would similarly use a Kafka client library to connect, subscribe to the topic, and receive incoming messages. 
