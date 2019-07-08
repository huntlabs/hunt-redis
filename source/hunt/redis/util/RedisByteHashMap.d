module hunt.redis.util.RedisByteHashMap;

import hunt.util.ArrayHelper;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import hunt.collection.Map;
import hunt.collection.Set;

class RedisByteHashMap : Map!(byte[], byte[]), Cloneable, Serializable {
  private transient Map!(ByteArrayWrapper, byte[]) internalMap = new HashMap!(ByteArrayWrapper, byte[])();

  override
  void clear() {
    internalMap.clear();
  }

  override
  bool containsKey(Object key) {
    if (key instanceof byte[]) return internalMap.containsKey(new ByteArrayWrapper((byte[]) key));
    return internalMap.containsKey(key);
  }

  override
  bool containsValue(Object value) {
    return internalMap.containsValue(value);
  }

  override
  Set<hunt.collection.Map.Entry!(byte[], byte[])> entrySet() {
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
  byte[] get(Object key) {
    if (key instanceof byte[]) return internalMap.get(new ByteArrayWrapper((byte[]) key));
    return internalMap.get(key);
  }

  override
  bool isEmpty() {
    return internalMap.isEmpty();
  }

  override
  Set!(byte[]) keySet() {
    Set!(byte[]) keySet = new HashSet!(byte[])();
    Iterator!(ByteArrayWrapper) iterator = internalMap.keySet().iterator();
    while (iterator.hasNext()) {
      keySet.add(iterator.next().data);
    }
    return keySet;
  }

  override
  byte[] put(byte[] key, byte[] value) {
    return internalMap.put(new ByteArrayWrapper(key), value);
  }

  override
  @SuppressWarnings("unchecked")
  void putAll(Map<? extends byte[], ? extends byte[]> m) {
    Iterator<?> iterator = m.entrySet().iterator();
    while (iterator.hasNext()) {
      Entry<? extends byte[], ? extends byte[]> next = (Entry<? extends byte[], ? extends byte[]>) iterator
          .next();
      internalMap.put(new ByteArrayWrapper(next.getKey()), next.getValue());
    }
  }

  override
  byte[] remove(Object key) {
    if (key instanceof byte[]) return internalMap.remove(new ByteArrayWrapper((byte[]) key));
    return internalMap.remove(key);
  }

  override
  int size() {
    return internalMap.size();
  }

  override
  Collection!(byte[]) values() {
    return internalMap.values();
  }

  private static final class ByteArrayWrapper {
    private final byte[] data;

    ByteArrayWrapper(byte[] data) {
      if (data == null) {
        throw new NullPointerException();
      }
      this.data = data;
    }

    override
    bool equals(Object other) {
      if (other == null) return false;
      if (other == this) return true;
      if (!(other instanceof ByteArrayWrapper)) return false;

      return Arrays.equals(data, ((ByteArrayWrapper) other).data);
    }

    override
    size_t toHash() @trusted nothrow() {
      return Arrays.hashCode(data);
    }
  }

  private static final class RedisByteEntry : Entry!(byte[], byte[]) {
    private byte[] value;
    private byte[] key;

    RedisByteEntry(byte[] key, byte[] value) {
      this.key = key;
      this.value = value;
    }

    override
    byte[] getKey() {
      return this.key;
    }

    override
    byte[] getValue() {
      return this.value;
    }

    override
    byte[] setValue(byte[] value) {
      this.value = value;
      return value;
    }

  }
}
