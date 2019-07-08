module hunt.redis;

import hunt.redis.Protocol.Keyword.AGGREGATE;
import hunt.redis.Protocol.Keyword.WEIGHTS;

import hunt.collection.ArraryList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

import hunt.redis.util.SafeEncoder;

public class ZParams {
  public enum Aggregate {
    SUM, MIN, MAX;

    public final byte[] raw;

    Aggregate() {
      raw = SafeEncoder.encode(name());
    }
  }

  private List<byte[]> params = new ArrayList<byte[]>();

  /**
   * Set weights.
   * @param weights weights.
   * @return 
   */
  public ZParams weights(final double... weights) {
    params.add(WEIGHTS.raw);
    for (final double weight : weights) {
      params.add(Protocol.toByteArray(weight));
    }

    return this;
  }

  public Collection<byte[]> getParams() {
    return Collections.unmodifiableCollection(params);
  }

  public ZParams aggregate(final Aggregate aggregate) {
    params.add(AGGREGATE.raw);
    params.add(aggregate.raw);
    return this;
  }
}
