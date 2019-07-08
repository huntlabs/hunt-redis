module hunt.redis.Exceptions;

import hunt.Exceptions;


class RedisException : RuntimeException {
}


class InvalidURIException : RedisException {
}

class RedisConnectionException : RedisException {
}

class RedisNoReachableClusterNodeException : RedisConnectionException {
}


class RedisDataException : RedisException {
}