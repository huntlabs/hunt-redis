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
 
module hunt.redis.commands.RedisClusterBinaryScriptingCommands;

import hunt.collection.List;
import hunt.Double;
import hunt.Long;

interface RedisClusterBinaryScriptingCommands {
    // Object eval(const(ubyte)[] script, const(ubyte)[] keyCount, const(ubyte)[][] params...);

    // Object eval(const(ubyte)[] script, int keyCount, const(ubyte)[][] params...);

    // Object eval(const(ubyte)[] script, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

    // /**
    //  * @param script
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // Object eval(const(ubyte)[] script, const(ubyte)[] sampleKey);

    // /**
    //  * @param sha1
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // Object evalsha(const(ubyte)[] sha1, const(ubyte)[] sampleKey);

    // Object evalsha(const(ubyte)[] sha1, List!(const(ubyte)[]) keys, List!(const(ubyte)[]) args);

    // Object evalsha(const(ubyte)[] sha1, int keyCount, const(ubyte)[][] params...);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @param sha1
    //  * @return 
    //  */
    // List!(Long) scriptExists(const(ubyte)[] sampleKey, const(ubyte)[][] sha1...);

    // /**
    //  * @param script
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // const(ubyte)[] scriptLoad(const(ubyte)[] script, const(ubyte)[] sampleKey);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // string scriptFlush(const(ubyte)[] sampleKey);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // string scriptKill(const(ubyte)[] sampleKey);
}
