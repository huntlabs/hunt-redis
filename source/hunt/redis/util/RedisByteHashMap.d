module hunt.redis.util.RedisByteHashMap;

import hunt.util.ArrayHelper;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import hunt.collection.Map;
import hunt.collection.Set;

public class RedisByteHashMap implements Map<byte[], byte[]>, Cloneable, Serializable {
  private static final long serialVersionUID = -6971431362627219416L;
  private transient Map<ByteArrayWrapper, byte[]> internalMap = new HashMap<ByteArrayWrapper, byte[]>();

  @Override
  public void clear() {
    internalMap.clear();
  }

  @Override
  public boolean containsKey(Object key) {
    if (key instanceof byte[]) return internalMap.containsKey(new ByteArrayWrapper((byte[]) key));
    return internalMap.containsKey(key);
  }

  @Override
  public boolean containsValue(Object value) {
    return internalMap.containsValue(value);
  }

  @Override
  public Set<hunt.collection.Map.Entry<byte[], byte[]>> entrySet() {
    Iterator<hunt.collection.Map.Entry<ByteArrayWrapper, byte[]>> iterator = internalMap.entrySet()
        .iterator();
    HashSet<Entry<byte[], byte[]>> hashSet = new HashSet<hunt.collection.Map.Entry<byte[], byte[]>>();
    while (iterator.hasNext()) {
      Entry<ByteArrayWrapper, byte[]> entry = iterator.next();
      hashSet.add(new RedisByteEntry(entry.getKey().data, entry.getValue()));
    }
    return hashSet;
  }

  @Override
  public byte[] get(Object key) {
    if (key instanceof byte[]) return internalMap.get(new ByteArrayWrapper((byte[]) key));
    return internalMap.get(key);
  }

  @Override
  public boolean isEmpty() {
    return internalMap.isEmpty();
  }

  @Override
  public Set<byte[]> keySet() {
    Set<byte[]> keySet = new HashSet<byte[]>();
    Iterator<ByteArrayWrapper> iterator = internalMap.keySet().iterator();
    while (iterator.hasNext()) {
      keySet.add(iterator.next().data);
    }
    return keySet;
  }

  @Override
  public byte[] put(byte[] key, byte[] value) {
    return internalMap.put(new ByteArrayWrapper(key), value);
  }

  @Override
  @SuppressWarnings("unchecked")
  public void putAll(Map<? extends byte[], ? extends byte[]> m) {
    Iterator<?> iterator = m.entrySet().iterator();
    while (iterator.hasNext()) {
      Entry<? extends byte[], ? extends byte[]> next = (Entry<? extends byte[], ? extends byte[]>) iterator
          .next();
      internalMap.put(new ByteArrayWrapper(next.getKey()), next.getValue());
    }
  }

  @Override
  public byte[] remove(Object key) {
    if (key instanceof byte[]) return internalMap.remove(new ByteArrayWrapper((byte[]) key));
    return internalMap.remove(key);
  }

  @Override
  public int size() {
    return internalMap.size();
  }

  @Override
  public Collection<byte[]> values() {
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

    @Override
    public boolean equals(Object other) {
      if (other == null) return false;
      if (other == this) return true;
      if (!(other instanceof ByteArrayWrapper)) return false;

      return Arrays.equals(data, ((ByteArrayWrapper) other).data);
    }

    @Override
    public int hashCode() {
      return Arrays.hashCode(data);
    }
  }

  private static final class RedisByteEntry implements Entry<byte[], byte[]> {
    private byte[] value;
    private byte[] key;

    public RedisByteEntry(byte[] key, byte[] value) {
      this.key = key;
      this.value = value;
    }

    @Override
    public byte[] getKey() {
      return this.key;
    }

    @Override
    public byte[] getValue() {
      return this.value;
    }

    @Override
    public byte[] setValue(byte[] value) {
      this.value = value;
      return value;
    }

  }
}
