module hunt.redis.RedisClusterHostAndPortMap;

import hunt.redis.HostAndPort;

interface RedisClusterHostAndPortMap {
  HostAndPort getSSLHostAndPort(string host, int port);
}
