module hunt.redis.BinaryRedisPubSub;

import hunt.redis.Client;
import hunt.redis.Exceptions;
import hunt.redis.Protocol;

import hunt.util.ArrayHelper;
import hunt.collection.List;
import hunt.Exceptions;

abstract class BinaryRedisPubSub {
  private int subscribedChannels = 0;
  private Client client;

  void onMessage(const(ubyte)[] channel, const(ubyte)[] message) {
  }

  void onPMessage(const(ubyte)[] pattern, const(ubyte)[] channel, const(ubyte)[] message) {
  }

  void onSubscribe(const(ubyte)[] channel, int subscribedChannels) {
  }

  void onUnsubscribe(const(ubyte)[] channel, int subscribedChannels) {
  }

  void onPUnsubscribe(const(ubyte)[] pattern, int subscribedChannels) {
  }

  void onPSubscribe(const(ubyte)[] pattern, int subscribedChannels) {
  }

  void unsubscribe() {
    client.unsubscribe();
    client.flush();
  }

  void unsubscribe(const(ubyte)[][] channels...) {
    client.unsubscribe(channels);
    client.flush();
  }

  void subscribe(const(ubyte)[][] channels...) {
    client.subscribe(channels);
    client.flush();
  }

  void psubscribe(const(ubyte)[][] patterns...) {
    client.psubscribe(patterns);
    client.flush();
  }

  void punsubscribe() {
    client.punsubscribe();
    client.flush();
  }

  void punsubscribe(const(ubyte)[][] patterns...) {
    client.punsubscribe(patterns);
    client.flush();
  }

  bool isSubscribed() {
    return subscribedChannels > 0;
  }

  void proceedWithPatterns(Client client, const(ubyte)[][] patterns...) {
    this.client = client;
    client.psubscribe(patterns);
    client.flush();
    process(client);
  }

  void proceed(Client client, const(ubyte)[][] channels...) {
    this.client = client;
    client.subscribe(channels);
    client.flush();
    process(client);
  }

  private void process(Client client) {
    implementationMissing(false);
    // do {
    //   List!(Object) reply = client.getUnflushedObjectMultiBulkReply();
    //   Object firstObj = reply.get(0);
    //   if (!(firstObj instanceof const(ubyte)[])) {
    //     throw new RedisException("Unknown message type: " ~ firstObj);
    //   }
    //   const(ubyte)[] resp = (const(ubyte)[]) firstObj;
    //   if (Arrays.equals(SUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     const(ubyte)[] bchannel = (const(ubyte)[]) reply.get(1);
    //     onSubscribe(bchannel, subscribedChannels);
    //   } else if (Arrays.equals(UNSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     const(ubyte)[] bchannel = (const(ubyte)[]) reply.get(1);
    //     onUnsubscribe(bchannel, subscribedChannels);
    //   } else if (Arrays.equals(MESSAGE.raw, resp)) {
    //     const(ubyte)[] bchannel = (const(ubyte)[]) reply.get(1);
    //     const(ubyte)[] bmesg = (const(ubyte)[]) reply.get(2);
    //     onMessage(bchannel, bmesg);
    //   } else if (Arrays.equals(PMESSAGE.raw, resp)) {
    //     const(ubyte)[] bpattern = (const(ubyte)[]) reply.get(1);
    //     const(ubyte)[] bchannel = (const(ubyte)[]) reply.get(2);
    //     const(ubyte)[] bmesg = (const(ubyte)[]) reply.get(3);
    //     onPMessage(bpattern, bchannel, bmesg);
    //   } else if (Arrays.equals(PSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     const(ubyte)[] bpattern = (const(ubyte)[]) reply.get(1);
    //     onPSubscribe(bpattern, subscribedChannels);
    //   } else if (Arrays.equals(PUNSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     const(ubyte)[] bpattern = (const(ubyte)[]) reply.get(1);
    //     onPUnsubscribe(bpattern, subscribedChannels);
    //   } else {
    //     throw new RedisException("Unknown message type: " ~ firstObj);
    //   }
    // } while (isSubscribed());
  }

  int getSubscribedChannels() {
    return subscribedChannels;
  }
}
