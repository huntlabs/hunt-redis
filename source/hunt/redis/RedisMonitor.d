module hunt.redis.RedisMonitor;

import hunt.redis.Client;

abstract class RedisMonitor {
  protected Client client;

  void proceed(Client client) {
    this.client = client;
    this.client.setTimeoutInfinite();
    do {
      string command = client.getBulkReply();
      onCommand(command);
    } while (client.isConnected());
  }

  abstract void onCommand(string command);
}