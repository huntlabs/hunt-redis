module hunt.redis.RedisClusterHostAndPortMap;

public interface RedisClusterHostAndPortMap {
  HostAndPort getSSLHostAndPort(String host, int port);
}
