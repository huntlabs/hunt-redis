/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
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