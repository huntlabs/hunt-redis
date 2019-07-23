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
  Object eval(byte[] script, byte[] keyCount, byte[][] params...);

  Object eval(byte[] script, int keyCount, byte[][] params...);

  Object eval(byte[] script, List!(byte[]) keys, List!(byte[]) args);

  /**
   * @param script
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @return 
   */
  Object eval(byte[] script, byte[] sampleKey);

  /**
   * @param sha1
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @return 
   */
  Object evalsha(byte[] sha1, byte[] sampleKey);

  Object evalsha(byte[] sha1, List!(byte[]) keys, List!(byte[]) args);

  Object evalsha(byte[] sha1, int keyCount, byte[][] params...);

  /**
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @param sha1
   * @return 
   */
  List!(Long) scriptExists(byte[] sampleKey, byte[][] sha1...);

  /**
   * @param script
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @return 
   */
  byte[] scriptLoad(byte[] script, byte[] sampleKey);

  /**
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @return 
   */
  string scriptFlush(byte[] sampleKey);

  /**
   * @param sampleKey Command will be executed in the node where the hash slot of this key is assigned to
   * @return 
   */
  string scriptKill(byte[] sampleKey);
}
