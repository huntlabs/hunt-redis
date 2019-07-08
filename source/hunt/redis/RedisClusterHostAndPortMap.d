module hunt.redis.RedisClusterHostAndPortMap;

public interface RedisClusterHostAndPortMap {
  HostAndPort getSSLHostAndPort(string host, int port);
}
