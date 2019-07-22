module hunt.redis.ZParams;

// import hunt.redis.Protocol.Keyword.AGGREGATE;
// import hunt.redis.Protocol.Keyword.WEIGHTS;

import hunt.redis.Protocol;

import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

import std.conv;

import hunt.redis.util.SafeEncoder;

enum Aggregate {
    SUM,
    MIN,
    MAX
}

class ZParams {

    private List!(const(ubyte)[]) params;

    this() {
        params = new ArrayList!(const(ubyte)[])();
    }

    /**
   * Set weights.
   * @param weights weights.
   * @return 
   */
    ZParams weights(double[] weights...) {
        params.add(SafeEncoder.encode(Protocol.Keyword.WEIGHTS.to!string()));
        foreach (double weight; weights) {
            params.add(Protocol.toByteArray(weight));
        }

        return this;
    }

    Collection!(const(ubyte)[]) getParams() {
        return params; // Collections.unmodifiableCollection(params);
    }

    ZParams aggregate(Aggregate aggregate) {
        params.add(SafeEncoder.encode(Protocol.Keyword.AGGREGATE.to!string()));
        params.add(SafeEncoder.encode(aggregate.to!string()));
        return this;
    }
}
