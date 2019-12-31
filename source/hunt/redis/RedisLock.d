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

    this(string redis_servers, string password="", bool initConnected = true) {

        auto hostports = redis_servers.split(";");
        foreach (hp; hostports) {
            if (hp == string.init)
                continue;

            string[] hpc = hp.split(":");

            try {
                Redis client = new Redis(hpc[0], to!ushort(hpc[1]));
                if(!password.empty)
                    client.auth(password);
                    
                _redisClients ~= client;
            } catch (Throwable e) {
                if (initConnected)
                    throw e;
                else
                    _hostports[hp] = true;
            }
        }

        _quornum = _redisClients.length / 2 + 1;

        _delaytime = 10;
        _clockFactor = 0.01;
    }

    void close() {
        foreach(Redis client; _redisClients) {
            client.close();
        }
    }

    bool lock(string key, ref LockedObject lock, uint timeout = uint.max, uint ttl = 60000) {
        string val = to!string(randomUUID());
        auto end_tick = nsecsToTicks(cast(long) timeout * 1000 * 1000) + MonoTime.currTime.ticks();
        synchronized (this) {
            lock.key = key;
            lock.uniqueId = val;

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
                    lock.validTime = cast(size_t)validtime;
                    return true;
                } else {
                    unlock(lock);
                }
                size_t delay = rand() % _delaytime + _delaytime / 2;
                Thread.sleep(dur!"msecs"(delay));
            } while (MonoTime.currTime.ticks() < end_tick);

            return false;
        }

    }

    void unlock(const ref LockedObject lock) {
        synchronized (this) {
            foreach (c; _redisClients) {
                unlockInstance(c, lock.key, lock.uniqueId);
            }

            if (_hostports !is null) {
                foreach (k; _hostports.keys) {
                    auto hpc = k.split(":");
                    try {
                        _redisClients ~= new Redis(hpc[0], to!ushort(hpc[1]));
                        _hostports.remove(k);
                    } catch (Throwable e) {
                        warning(e);
                    }
                }
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

    Redis[] _redisClients;

    bool[string] _hostports;

    immutable size_t _quornum;
    immutable size_t _delaytime = 10;
    immutable float _clockFactor = 0.01;

    static immutable string _prefix = "hunt_redlock_";
}

