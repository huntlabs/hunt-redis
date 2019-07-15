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

  void onMessage(byte[] channel, byte[] message) {
  }

  void onPMessage(byte[] pattern, byte[] channel, byte[] message) {
  }

  void onSubscribe(byte[] channel, int subscribedChannels) {
  }

  void onUnsubscribe(byte[] channel, int subscribedChannels) {
  }

  void onPUnsubscribe(byte[] pattern, int subscribedChannels) {
  }

  void onPSubscribe(byte[] pattern, int subscribedChannels) {
  }

  void unsubscribe() {
    client.unsubscribe();
    client.flush();
  }

  void unsubscribe(byte[][] channels...) {
    client.unsubscribe(channels);
    client.flush();
  }

  void subscribe(byte[][] channels...) {
    client.subscribe(channels);
    client.flush();
  }

  void psubscribe(byte[][] patterns...) {
    client.psubscribe(patterns);
    client.flush();
  }

  void punsubscribe() {
    client.punsubscribe();
    client.flush();
  }

  void punsubscribe(byte[][] patterns...) {
    client.punsubscribe(patterns);
    client.flush();
  }

  bool isSubscribed() {
    return subscribedChannels > 0;
  }

  void proceedWithPatterns(Client client, byte[][] patterns...) {
    this.client = client;
    client.psubscribe(patterns);
    client.flush();
    process(client);
  }

  void proceed(Client client, byte[][] channels...) {
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
    //   if (!(firstObj instanceof byte[])) {
    //     throw new RedisException("Unknown message type: " ~ firstObj);
    //   }
    //   byte[] resp = (byte[]) firstObj;
    //   if (Arrays.equals(SUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     byte[] bchannel = (byte[]) reply.get(1);
    //     onSubscribe(bchannel, subscribedChannels);
    //   } else if (Arrays.equals(UNSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     byte[] bchannel = (byte[]) reply.get(1);
    //     onUnsubscribe(bchannel, subscribedChannels);
    //   } else if (Arrays.equals(MESSAGE.raw, resp)) {
    //     byte[] bchannel = (byte[]) reply.get(1);
    //     byte[] bmesg = (byte[]) reply.get(2);
    //     onMessage(bchannel, bmesg);
    //   } else if (Arrays.equals(PMESSAGE.raw, resp)) {
    //     byte[] bpattern = (byte[]) reply.get(1);
    //     byte[] bchannel = (byte[]) reply.get(2);
    //     byte[] bmesg = (byte[]) reply.get(3);
    //     onPMessage(bpattern, bchannel, bmesg);
    //   } else if (Arrays.equals(PSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     byte[] bpattern = (byte[]) reply.get(1);
    //     onPSubscribe(bpattern, subscribedChannels);
    //   } else if (Arrays.equals(PUNSUBSCRIBE.raw, resp)) {
    //     subscribedChannels = ((Long) reply.get(2)).intValue();
    //     byte[] bpattern = (byte[]) reply.get(1);
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
