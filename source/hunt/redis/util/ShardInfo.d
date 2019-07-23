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
 
module hunt.redis.util.ShardInfo;

abstract class ShardInfo(T) {
  private int weight;

  this() {
  }

  this(int weight) {
    this.weight = weight;
  }

  int getWeight() {
    return this.weight;
  }

  protected abstract T createResource();

  abstract string getName();
}
