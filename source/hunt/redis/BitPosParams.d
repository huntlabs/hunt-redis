module hunt.redis.BitPosParams;

import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

class BitPosParams {
  private List!(byte[]) params;

  this() {
    params = new ArrayList!(byte[])();
  }

  this(long start) {
    this();
    params.add(Protocol.toByteArray(start));
  }

  this(long start, long end) {
    this(start);

    params.add(Protocol.toByteArray(end));
  }

  Collection!(byte[]) getParams() {
    // return Collections.unmodifiableCollection(params);
    return params;
  }
}
