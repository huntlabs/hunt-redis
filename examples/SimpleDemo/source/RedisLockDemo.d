module RedisLockDemo;

import hunt.redis;

import hunt.logging.ConsoleLogger;

import core.thread;
import std.stdio;
import std.conv;

// string RedisHosts = "10.1.11.115:6379;10.1.11.115:6380;10.1.11.115:6381;10.1.11.115:7000;10.1.11.115:7001;10.1.11.115:7002";
string RedisHosts = "10.1.222.120:6379";

void run()
{

    TestThread[] list;
    for (uint i = 0; i < 10; i++)
    {
        auto test = new TestThread("client " ~ to!string(i), 1);
        test.start();
        list ~= test;
    }

    Thread.sleep(dur!"seconds"(5));

    foreach (t; list)
    {
        t.stop();
    }

    int i = 0;
    i++;
    // foreach (t; list)
    //     t.join();

}

class TestThread : Thread
{
    string _name;
    int _second;
    bool _flag;
    RedisLock _lock;

    this(string name, int second)
    {
        super(&run);
        _name = name;
        _second = second;
        _lock = new RedisLock(RedisHosts, "foobared");
        _flag = true;
    }

    void stop()
    {
        if(_flag) {
            _flag = false;
            _lock.close();
        }
    }

    void run()
    {
        while (_flag)
        {
            LockedObject obj;
            if (!_lock.lock("test1", obj, 1000))
            {
                warningf(" timeout: %s ", _name);
                continue;
            }

            info(_name, " locked");
            Thread.sleep(dur!"msecs"(500));
            info(_name, " unlocked");
            _lock.unlock(obj);
            Thread.sleep(dur!"seconds"(1));
        }

    }
}
