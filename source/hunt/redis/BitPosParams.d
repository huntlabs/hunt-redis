module hunt.redis;

import hunt.collection.ArraryList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

public class BitPosParams {
  private List<byte[]> params = new ArrayList<byte[]>();

  protected BitPosParams() {
  }

  public BitPosParams(long start) {
    params.add(Protocol.toByteArray(start));
  }

  public BitPosParams(long start, long end) {
    this(start);

    params.add(Protocol.toByteArray(end));
  }

  public Collection<byte[]> getParams() {
    return Collections.unmodifiableCollection(params);
  }
}
