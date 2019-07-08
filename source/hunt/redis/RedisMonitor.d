module hunt.redis.RedisMonitor;

abstract class RedisMonitor {
  protected Client client;

  void proceed(Client client) {
    this.client = client;
    this.client.setTimeoutInfinite();
    do {
      String command = client.getBulkReply();
      onCommand(command);
    } while (client.isConnected());
  }

  abstract void onCommand(String command);
}