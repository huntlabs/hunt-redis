module hunt.redis.BitPosParams;

import hunt.collection.ArraryList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

class BitPosParams {
  private List!(byte[]) params = new ArrayList!(byte[])();

  protected BitPosParams() {
  }

  BitPosParams(long start) {
    params.add(Protocol.toByteArray(start));
  }

  BitPosParams(long start, long end) {
    this(start);

    params.add(Protocol.toByteArray(end));
  }

  Collection!(byte[]) getParams() {
    return Collections.unmodifiableCollection(params);
  }
}
