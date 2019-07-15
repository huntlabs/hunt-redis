module hunt.redis.util.RedisByteHashMap;

import hunt.util.ArrayHelper;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Byte;

alias RedisByteHashMap = HashMap!(byte[], byte[]);

// class RedisByteHashMap : Map!(byte[], byte[]), Cloneable { // , Serializable 
//   private Map!(Bytes, byte[]) internalMap = new HashMap!(ByteArrayWrapper, byte[])();

//   this() {
//       internalMap = new HashMap!(Bytes, byte[])();
//   }

//   override
//   void clear() {
//     internalMap.clear();
//   }

//   override
//   bool containsKey(byte[] key) {
//     // if (key instanceof byte[]) return internalMap.containsKey(new ByteArrayWrapper((byte[]) key));
//     // return internalMap.containsKey(key);
//     return internalMap.containsKey(new Bytes(key));
//   }

//   override
//   bool containsValue(byte[] value) {
//     return internalMap.containsValue(value);
//   }

// //   override
// //   Set<hunt.collection.MapEntry!(byte[], byte[])> entrySet() {
// //     Iterator<hunt.collection.MapEntry!(ByteArrayWrapper, byte[])> iterator = internalMap.entrySet()
// //         .iterator();
// //     HashSet!(Entry!(byte[], byte[])) hashSet = new HashSet<hunt.collection.MapEntry!(byte[], byte[])>();
// //     while (iterator.hasNext()) {
// //       Entry!(ByteArrayWrapper, byte[]) entry = iterator.next();
// //       hashSet.add(new RedisByteEntry(entry.getKey().data, entry.getValue()));
// //     }
// //     return hashSet;
// //   }

//   override
//   byte[] get(byte[] key) {
//     // if (key instanceof byte[]) return internalMap.get(new ByteArrayWrapper((byte[]) key));
//     // return internalMap.get(key);
//     return internalMap.get(new Bytes(key));
//   }

//   override
//   bool isEmpty() {
//     return internalMap.isEmpty();
//   }


// override InputRange!(byte[]) byKey() {
//     return internalMap.byKey();
// }

// override InputRange!(byte[]) byValue() {
//     return internalMap.byValue();
// }

//     override int opApply(scope int delegate(byte[], byte[]) dg) {
//         int r = 0;
//         foreach(Bytes key, byte[] value; internalMap) {
//             r = dg(key.value, value);
//         }

//         return r;
//     }

//   override
//   byte[] put(byte[] key, byte[] value) {
//     return internalMap.put(new Bytes(key), value);
//   }

// //   override
  
// //   void putAll(Map<? extends byte[], ? extends byte[]> m) {
// //     Iterator<?> iterator = m.entrySet().iterator();
// //     while (iterator.hasNext()) {
// //       Entry<? extends byte[], ? extends byte[]> next = (Entry<? extends byte[], ? extends byte[]>) iterator
// //           .next();
// //       internalMap.put(new ByteArrayWrapper(next.getKey()), next.getValue());
// //     }
// //   }

//   override
//   byte[] remove(byte[] key) {
//     return internalMap.remove(new Bytes(key));
//   }

//   override
//   int size() {
//     return internalMap.size();
//   }

//   override
//   byte[][] values() {
//     return internalMap.values();
//   }

// }
