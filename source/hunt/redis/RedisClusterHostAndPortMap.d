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

module hunt.redis.RedisClusterHostAndPortMap;

import hunt.redis.HostAndPort;

interface RedisClusterHostAndPortMap {
    HostAndPort getSSLHostAndPort(string host, int port);
}
