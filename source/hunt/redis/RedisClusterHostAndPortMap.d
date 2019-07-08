module hunt.redis;

public interface RedisClusterHostAndPortMap {
  HostAndPort getSSLHostAndPort(String host, int port);
}
