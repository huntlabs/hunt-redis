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

  void onMessage(string channel, string message) {
  }

  void onPMessage(string pattern, string channel, string message) {
  }

  void onSubscribe(string channel, int subscribedChannels) {
  }

  void onUnsubscribe(string channel, int subscribedChannels) {
  }

  void onPUnsubscribe(string pattern, int subscribedChannels) {
  }

  void onPSubscribe(string pattern, int subscribedChannels) {
  }

  void onPong(string pattern) {

  }

  void unsubscribe() {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.unsubscribe();
    client.flush();
  }

  void unsubscribe(string channels...) {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.unsubscribe(channels);
    client.flush();
  }

  void subscribe(string channels...) {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.subscribe(channels);
    client.flush();
  }

  void psubscribe(string patterns...) {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.psubscribe(patterns);
    client.flush();
  }

  void punsubscribe() {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.punsubscribe();
    client.flush();
  }

  void punsubscribe(string patterns...) {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.punsubscribe(patterns);
    client.flush();
  }

  void ping() {
    if (client is null) {
      throw new RedisConnectionException(JEDIS_SUBSCRIPTION_MESSAGE);
    }
    client.ping();
    client.flush();
  }

  bool isSubscribed() {
    return subscribedChannels > 0;
  }

  void proceedWithPatterns(Client client, string patterns...) {
    this.client = client;
    client.psubscribe(patterns);
    client.flush();
    process(client);
  }

  void proceed(Client client, string channels...) {
    this.client = client;
    client.subscribe(channels);
    client.flush();
    process(client);
  }

  private void process(Client client) {

    do {
      List!(Object) reply = client.getUnflushedObjectMultiBulkReply();
      Object firstObj = reply.get(0);
      if (!(firstObj instanceof byte[])) {
        throw new RedisException("Unknown message type: " ~ firstObj);
      }
      byte[] resp = (byte[]) firstObj;
      if (Arrays.equals(SUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        byte[] bchannel = (byte[]) reply.get(1);
        string strchannel = (bchannel is null) ? null : SafeEncoder.encode(bchannel);
        onSubscribe(strchannel, subscribedChannels);
      } else if (Arrays.equals(UNSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        byte[] bchannel = (byte[]) reply.get(1);
        string strchannel = (bchannel is null) ? null : SafeEncoder.encode(bchannel);
        onUnsubscribe(strchannel, subscribedChannels);
      } else if (Arrays.equals(MESSAGE.raw, resp)) {
        byte[] bchannel = (byte[]) reply.get(1);
        byte[] bmesg = (byte[]) reply.get(2);
        string strchannel = (bchannel is null) ? null : SafeEncoder.encode(bchannel);
        string strmesg = (bmesg is null) ? null : SafeEncoder.encode(bmesg);
        onMessage(strchannel, strmesg);
      } else if (Arrays.equals(PMESSAGE.raw, resp)) {
        byte[] bpattern = (byte[]) reply.get(1);
        byte[] bchannel = (byte[]) reply.get(2);
        byte[] bmesg = (byte[]) reply.get(3);
        string strpattern = (bpattern is null) ? null : SafeEncoder.encode(bpattern);
        string strchannel = (bchannel is null) ? null : SafeEncoder.encode(bchannel);
        string strmesg = (bmesg is null) ? null : SafeEncoder.encode(bmesg);
        onPMessage(strpattern, strchannel, strmesg);
      } else if (Arrays.equals(PSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        byte[] bpattern = (byte[]) reply.get(1);
        string strpattern = (bpattern is null) ? null : SafeEncoder.encode(bpattern);
        onPSubscribe(strpattern, subscribedChannels);
      } else if (Arrays.equals(PUNSUBSCRIBE.raw, resp)) {
        subscribedChannels = ((Long) reply.get(2)).intValue();
        byte[] bpattern = (byte[]) reply.get(1);
        string strpattern = (bpattern is null) ? null : SafeEncoder.encode(bpattern);
        onPUnsubscribe(strpattern, subscribedChannels);
      } else if (Arrays.equals(PONG.raw, resp)) {
        byte[] bpattern = (byte[]) reply.get(1);
        string strpattern = (bpattern is null) ? null : SafeEncoder.encode(bpattern);
        onPong(strpattern);
      } else {
        throw new RedisException("Unknown message type: " ~ firstObj);
      }
    } while (isSubscribed());

    /* Invalidate instance since this thread is no longer listening */
    this.client = null;
  }

  int getSubscribedChannels() {
    return subscribedChannels;
  }
}
