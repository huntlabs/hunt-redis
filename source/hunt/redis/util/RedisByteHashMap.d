module hunt.redis.util.RedisByteHashMap;

import hunt.util.ArrayHelper;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import hunt.collection.Map;
import hunt.collection.Set;

public class RedisByteHashMap : Map!(byte[], byte[]), Cloneable, Serializable {
  private transient Map!(ByteArrayWrapper, byte[]) internalMap = new HashMap!(ByteArrayWrapper, byte[])();

  override
  public void clear() {
    internalMap.clear();
  }

  override
  public boolean containsKey(Object key) {
    if (key instanceof byte[]) return internalMap.containsKey(new ByteArrayWrapper((byte[]) key));
    return internalMap.containsKey(key);
  }

  override
  public boolean containsValue(Object value) {
    return internalMap.containsValue(value);
  }

  override
  public Set<hunt.collection.Map.Entry!(byte[], byte[])> entrySet() {
    Iterator<hunt.collection.Map.Entry!(ByteArrayWrapper, byte[])> iterator = internalMap.entrySet()
        .iterator();
    HashSet!(Entry!(byte[], byte[])) hashSet = new HashSet<hunt.collection.Map.Entry!(byte[], byte[])>();
    while (iterator.hasNext()) {
      Entry!(ByteArrayWrapper, byte[]) entry = iterator.next();
      hashSet.add(new RedisByteEntry(entry.getKey().data, entry.getValue()));
    }
    return hashSet;
  }

  override
  public byte[] get(Object key) {
    if (key instanceof byte[]) return internalMap.get(new ByteArrayWrapper((byte[]) key));
    return internalMap.get(key);
  }

  override
  public boolean isEmpty() {
    return internalMap.isEmpty();
  }

  override
  public Set!(byte[]) keySet() {
    Set!(byte[]) keySet = new HashSet!(byte[])();
    Iterator!(ByteArrayWrapper) iterator = internalMap.keySet().iterator();
    while (iterator.hasNext()) {
      keySet.add(iterator.next().data);
    }
    return keySet;
  }

  override
  public byte[] put(byte[] key, byte[] value) {
    return internalMap.put(new ByteArrayWrapper(key), value);
  }

  override
  @SuppressWarnings("unchecked")
  public void putAll(Map<? extends byte[], ? extends byte[]> m) {
    Iterator<?> iterator = m.entrySet().iterator();
    while (iterator.hasNext()) {
      Entry<? extends byte[], ? extends byte[]> next = (Entry<? extends byte[], ? extends byte[]>) iterator
          .next();
      internalMap.put(new ByteArrayWrapper(next.getKey()), next.getValue());
    }
  }

  override
  public byte[] remove(Object key) {
    if (key instanceof byte[]) return internalMap.remove(new ByteArrayWrapper((byte[]) key));
    return internalMap.remove(key);
  }

  override
  public int size() {
    return internalMap.size();
  }

  override
  public Collection!(byte[]) values() {
    return internalMap.values();
  }

  private static final class ByteArrayWrapper {
    private final byte[] data;

    public ByteArrayWrapper(byte[] data) {
      if (data == null) {
        throw new NullPointerException();
      }
      this.data = data;
    }

    override
    public boolean equals(Object other) {
      if (other == null) return false;
      if (other == this) return true;
      if (!(other instanceof ByteArrayWrapper)) return false;

      return Arrays.equals(data, ((ByteArrayWrapper) other).data);
    }

    override
    public size_t toHash() @trusted nothrow() {
      return Arrays.hashCode(data);
    }
  }

  private static final class RedisByteEntry : Entry!(byte[], byte[]) {
    private byte[] value;
    private byte[] key;

    public RedisByteEntry(byte[] key, byte[] value) {
      this.key = key;
      this.value = value;
    }

    override
    public byte[] getKey() {
      return this.key;
    }

    override
    public byte[] getValue() {
      return this.value;
    }

    override
    public byte[] setValue(byte[] value) {
      this.value = value;
      return value;
    }

  }
}
