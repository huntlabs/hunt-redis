module hunt.redis.ZParams;

import hunt.redis.Protocol.Keyword.AGGREGATE;
import hunt.redis.Protocol.Keyword.WEIGHTS;

import hunt.collection.ArraryList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

import hunt.redis.util.SafeEncoder;

class ZParams {
  enum Aggregate {
    SUM, MIN, MAX;

    final byte[] raw;

    Aggregate() {
      raw = SafeEncoder.encode(name());
    }
  }

  private List!(byte[]) params = new ArrayList!(byte[])();

  /**
   * Set weights.
   * @param weights weights.
   * @return 
   */
  ZParams weights(final double weights...) {
    params.add(WEIGHTS.raw);
    foreach(final double weight ; weights) {
      params.add(Protocol.toByteArray(weight));
    }

    return this;
  }

  Collection!(byte[]) getParams() {
    return Collections.unmodifiableCollection(params);
  }

  ZParams aggregate(final Aggregate aggregate) {
    params.add(AGGREGATE.raw);
    params.add(aggregate.raw);
    return this;
  }
}
