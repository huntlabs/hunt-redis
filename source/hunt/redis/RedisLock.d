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
 
module hunt.redis.RedisLock;

import std.array;
import std.string;
import std.random;
import std.conv;
import std.stdio;
import std.uuid;

import core.time;
import core.thread;
import core.stdc.stdlib;

import hunt.logging.ConsoleLogger;
import hunt.redis.Redis;
import hunt.redis.params.SetParams;


struct LockedObject {
    string key;
    string uniqueId;
    size_t validTime;
}

/**
    https://redis.io/topics/distlock
    https://github.com/abelaska/jedis-lock
*/
class RedisLock {

    private Redis[] _redisClients;
    private LockedObject _lock;
    private string _lockKey;


    this(Redis client, string lockKey, int delaytime = 10, float clockFactor = 0.01f) {
        this([client], lockKey, delaytime, clockFactor);
    }

    this(Redis[] client, string lockKey, int delaytime = 10, float clockFactor = 0.01f) {
        _redisClients = client;
        _lockKey = lockKey;

        _quornum = _redisClients.length / 2 + 1;
        _delaytime = delaytime;
        _clockFactor = clockFactor;        
    }

    bool lock(uint timeout = uint.max, uint ttl = 60000) {
        string key = _lockKey;
        string val = to!string(randomUUID());
        auto end_tick = nsecsToTicks(cast(long) timeout * 1000 * 1000) + MonoTime.currTime.ticks();
        synchronized (this) {
            _lock.key = key;
            _lock.uniqueId = val;

            do {
                size_t n = 0;
                auto t1 = MonoTime.currTime.ticks();
                foreach (c; _redisClients) {
                    if (lockInstance(c, key, val, ttl))
                        ++n;
                }

                auto t2 = MonoTime.currTime.ticks();
                auto clockdrat = cast(size_t)(_clockFactor * ttl) + 2;
                auto validtime = ttl - ticksToNSecs(t2 - t1) / 1000 - clockdrat;

                version(HUNT_REDIS_DEBUG) {
                    tracef("validtime=%d, n=%d, _quornum=%d", validtime, n, _quornum);
                }


                if (validtime > 0 && n >= _quornum) {
                    _lock.validTime = cast(size_t)validtime;
                    return true;
                } else {
                    unlock();
                }
                size_t delay = rand() % _delaytime + _delaytime / 2;
                Thread.sleep(dur!"msecs"(delay));
            } while (MonoTime.currTime.ticks() < end_tick);

            return false;
        }

    }

    void unlock() {
        synchronized (this) {
            foreach (c; _redisClients) {
                unlockInstance(c, _lock.key, _lock.uniqueId);
            }
        }
    }

    private static bool lockInstance(Redis redis, string key, string value, long ttl) {
        try {
            SetParams para = new SetParams();
            string r = redis.set(_prefix ~ key, value, para.nx().px(ttl));
            return r == "OK";
        } catch (Throwable e) {
            warning(e);
            return false;
        }
    }

    private static void unlockInstance(Redis redis, string key, string value) {
        try {
            Object r = redis.eval(`if redis.call('get', KEYS[1]) == ARGV[1] 
                            then return redis.call('del', KEYS[1])
                        else 
                            return 0 
                        end`,
                    [_prefix ~ key], [value]);
        } catch (Throwable e) {
            warning(e);
        }

    }


    immutable size_t _quornum;
    immutable size_t _delaytime = 10;
    immutable float _clockFactor = 0.01;

    static immutable string _prefix = "hunt_redlock_";
}

