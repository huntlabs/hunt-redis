/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.redis.util.RedisByteHashMap;

import hunt.util.ArrayHelper;
import hunt.collection.Collection;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.Byte;

alias RedisByteHashMap = HashMap!(const(ubyte)[], const(ubyte)[]);

// class RedisByteHashMap : Map!(const(ubyte)[], const(ubyte)[]), Cloneable { // , Serializable 
//   private Map!(Bytes, const(ubyte)[]) internalMap = new HashMap!(ByteArrayWrapper, const(ubyte)[])();

//   this() {
//       internalMap = new HashMap!(Bytes, const(ubyte)[])();
//   }

//   override
//   void clear() {
//     internalMap.clear();
//   }

//   override
//   bool containsKey(const(ubyte)[] key) {
//     // if (key instanceof const(ubyte)[]) return internalMap.containsKey(new ByteArrayWrapper((const(ubyte)[]) key));
//     // return internalMap.containsKey(key);
//     return internalMap.containsKey(new Bytes(key));
//   }

//   override
//   bool containsValue(const(ubyte)[] value) {
//     return internalMap.containsValue(value);
//   }

// //   override
// //   Set<hunt.collection.MapEntry!(const(ubyte)[], const(ubyte)[])> entrySet() {
// //     Iterator<hunt.collection.MapEntry!(ByteArrayWrapper, const(ubyte)[])> iterator = internalMap.entrySet()
// //         .iterator();
// //     HashSet!(Entry!(const(ubyte)[], const(ubyte)[])) hashSet = new HashSet<hunt.collection.MapEntry!(const(ubyte)[], const(ubyte)[])>();
// //     while (iterator.hasNext()) {
// //       Entry!(ByteArrayWrapper, const(ubyte)[]) entry = iterator.next();
// //       hashSet.add(new RedisByteEntry(entry.getKey().data, entry.getValue()));
// //     }
// //     return hashSet;
// //   }

//   override
//   const(ubyte)[] get(const(ubyte)[] key) {
//     // if (key instanceof const(ubyte)[]) return internalMap.get(new ByteArrayWrapper((const(ubyte)[]) key));
//     // return internalMap.get(key);
//     return internalMap.get(new Bytes(key));
//   }

//   override
//   bool isEmpty() {
//     return internalMap.isEmpty();
//   }


// override InputRange!(const(ubyte)[]) byKey() {
//     return internalMap.byKey();
// }

// override InputRange!(const(ubyte)[]) byValue() {
//     return internalMap.byValue();
// }

//     override int opApply(scope int delegate(const(ubyte)[], const(ubyte)[]) dg) {
//         int r = 0;
//         foreach(Bytes key, const(ubyte)[] value; internalMap) {
//             r = dg(key.value, value);
//         }

//         return r;
//     }

//   override
//   const(ubyte)[] put(const(ubyte)[] key, const(ubyte)[] value) {
//     return internalMap.put(new Bytes(key), value);
//   }

// //   override
  
// //   void putAll(Map<? extends const(ubyte)[], ? extends const(ubyte)[]> m) {
// //     Iterator<?> iterator = m.entrySet().iterator();
// //     while (iterator.hasNext()) {
// //       Entry<? extends const(ubyte)[], ? extends const(ubyte)[]> next = (Entry<? extends const(ubyte)[], ? extends const(ubyte)[]>) iterator
// //           .next();
// //       internalMap.put(new ByteArrayWrapper(next.getKey()), next.getValue());
// //     }
// //   }

//   override
//   const(ubyte)[] remove(const(ubyte)[] key) {
//     return internalMap.remove(new Bytes(key));
//   }

//   override
//   int size() {
//     return internalMap.size();
//   }

//   override
//   const(ubyte)[][] values() {
//     return internalMap.values();
//   }

// }
