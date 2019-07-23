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
 
module hunt.redis.util.RedisURIHelper;

import hunt.net.util.HttpURI;

import hunt.Exceptions;

import std.array;
import std.conv;
import std.string;

class RedisURIHelper {

  private enum int DEFAULT_DB = 0;

  private enum string REDIS = "redis";
  private enum string REDISS = "rediss";

  private this(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  static string getPassword(HttpURI uri) {
    string userInfo = uri.getUser();
    if (userInfo !is null) {
      return userInfo.split(":")[1];
    }
    return null;
  }

  static int getDBIndex(HttpURI uri) {
    string[] pathSplit = uri.getPath().split("/");
    if (pathSplit.length > 1) {
      string dbIndexStr = pathSplit[1];
      if (dbIndexStr.empty()) {
        return DEFAULT_DB;
      }
      return to!int(dbIndexStr);
    } else {
      return DEFAULT_DB;
    }
  }

  static bool isValid(HttpURI uri) {
    if (isEmpty(uri.getScheme()) || isEmpty(uri.getHost()) || uri.getPort() == -1) {
      return false;
    }

    return true;
  }

  private static bool isEmpty(string value) {
    return value.empty();
  }

  static bool isRedisScheme(HttpURI uri) {
    return REDIS == uri.getScheme();
  }

  static bool isRedisSSLScheme(HttpURI uri) {
    return REDISS == uri.getScheme();
  }

}
