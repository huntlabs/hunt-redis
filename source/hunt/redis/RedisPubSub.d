module hunt.redis.RedisPubSub;

import hunt.redis.Protocol.Keyword.MESSAGE;
import hunt.redis.Protocol.Keyword.PMESSAGE;
import hunt.redis.Protocol.Keyword.PSUBSCRIBE;
import hunt.redis.Protocol.Keyword.PUNSUBSCRIBE;
import hunt.redis.Protocol.Keyword.SUBSCRIBE;
import hunt.redis.Protocol.Keyword.UNSUBSCRIBE;
import hunt.redis.Protocol.Keyword.PONG;

import hunt.util.ArrayHelper;
import hunt.collection.List;

import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.exceptions.RedisException;
import hunt.redis.util.SafeEncoder;

abstract class RedisPubSub {

  private enum string JEDIS_SUBSCRIPTION_MESSAGE = "RedisPubSub is not subscribed to a Redis instance.";
  private int subscribedChannels = 0;
  private volatile Client client;

  void onMessage(String channel, String message) {
  }

  void onPMessage(String pattern, String channel, String message) {
  }

  void onSubscribe(String channel, int subscribedChannels) {
  }

  void onUnsubscribe(String channel, int subscribedChannels) {
  }

  void onPUnsubscribe(String pattern, int subscribedChannels) {
  }

  void onPSubscribe(String pattern, int subscribedChannels) {
  }

  void onPong(String pattern) {

  }

  void unsubscribe() {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.unsubscribe();
    client.flush();
  }

  void unsubscribe(String channels...) {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.unsubscribe(channels);
    client.flush();
  }

  void subscribe(String channels...) {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.subscribe(channels);
    client.flush();
  }

  void psubscribe(String patterns...) {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.psubscribe(patterns);
    client.flush();
  }

  void punsubscribe() {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.punsubscribe();
    client.flush();
  }

  void punsubscribe(String patterns...) {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.punsubscribe(patterns);
    client.flush();
  }

  void ping() {
    if (client == null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.ping();
    client.flush();
  }

  bool isSubscribed() {
    return subscribedChannels > 0;
  }

  void proceedWithPatterns(Client client, String patterns...) {
    this.client = client;
    client.psubscribe(patterns);
    client.flush();
    process(client);
  }

  void proceed(Client client, String channels...) {
    this.client = client;
    client.subscribe(channels);
    client.flush();
    process(client);
  }

  private void process(Client client) {

    do {
      List!(Object) reply = client.getUnflushedObjectMultiBulkReply();
      final Object firstObj = reply.get(0);
      if (!(firstObj instanceof byte[])) {
        throw new RedisException("Unknown message type: " + firstObj);
      }
      final byte[] resp = (byte[]) firstObj;
      if (Arrays.equals(SUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        final byte[] bchannel = (byte[]) reply.get(1);
        final String strchannel = (bchannel == null) ? null : SafeEncoder.encode(bchannel);
        onSubscribe(strchannel, subscribedChannels);
      } else if (Arrays.equals(UNSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        final byte[] bchannel = (byte[]) reply.get(1);
        final String strchannel = (bchannel == null) ? null : SafeEncoder.encode(bchannel);
        onUnsubscribe(strchannel, subscribedChannels);
      } else if (Arrays.equals(MESSAGE.raw, resp)) {
        final byte[] bchannel = (byte[]) reply.get(1);
        final byte[] bmesg = (byte[]) reply.get(2);
        final String strchannel = (bchannel == null) ? null : SafeEncoder.encode(bchannel);
        final String strmesg = (bmesg == null) ? null : SafeEncoder.encode(bmesg);
        onMessage(strchannel, strmesg);
      } else if (Arrays.equals(PMESSAGE.raw, resp)) {
        final byte[] bpattern = (byte[]) reply.get(1);
        final byte[] bchannel = (byte[]) reply.get(2);
        final byte[] bmesg = (byte[]) reply.get(3);
        final String strpattern = (bpattern == null) ? null : SafeEncoder.encode(bpattern);
        final String strchannel = (bchannel == null) ? null : SafeEncoder.encode(bchannel);
        final String strmesg = (bmesg == null) ? null : SafeEncoder.encode(bmesg);
        onPMessage(strpattern, strchannel, strmesg);
      } else if (Arrays.equals(PSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        final byte[] bpattern = (byte[]) reply.get(1);
        final String strpattern = (bpattern == null) ? null : SafeEncoder.encode(bpattern);
        onPSubscribe(strpattern, subscribedChannels);
      } else if (Arrays.equals(PUNSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        final byte[] bpattern = (byte[]) reply.get(1);
        final String strpattern = (bpattern == null) ? null : SafeEncoder.encode(bpattern);
        onPUnsubscribe(strpattern, subscribedChannels);
      } else if (Arrays.equals(PONG.raw, resp)) {
        final byte[] bpattern = (byte[]) reply.get(1);
        final String strpattern = (bpattern == null) ? null : SafeEncoder.encode(bpattern);
        onPong(strpattern);
      } else {
        throw new RedisException("Unknown message type: " + firstObj);
      }
    } while (isSubscribed());

    /* Invalidate instance since this thread is no longer listening */
    this.client = null;
  }

  int getSubscribedChannels() {
    return subscribedChannels;
  }
}
