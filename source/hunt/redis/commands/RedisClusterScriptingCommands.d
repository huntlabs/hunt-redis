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
 
module hunt.redis.commands.RedisClusterScriptingCommands;

import hunt.collection.List;
import hunt.Boolean;


interface RedisClusterScriptingCommands {
    // Object eval(string script, int keyCount, string[] params...);

    // Object eval(string script, List!(string) keys, List!(string) args);

    // /**
    //  * @param script
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // Object eval(string script, string sampleKey);

    // /**
    //  * @param sha1
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // Object evalsha(string sha1, string sampleKey);

    // Object evalsha(string sha1, List!(string) keys, List!(string) args);

    // Object evalsha(string sha1, int keyCount, string[] params...);

    // /**
    //  * @param sha1
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // bool scriptExists(string sha1, string sampleKey);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @param sha1
    //  * @return 
    //  */
    // bool[] scriptExists(string sampleKey, string[] sha1...);

    // /**
    //  * @param script
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // string scriptLoad(string script, string sampleKey);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // string scriptFlush(string sampleKey);

    // /**
    //  * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
    //  * @return 
    //  */
    // string scriptKill(string sampleKey);
}
