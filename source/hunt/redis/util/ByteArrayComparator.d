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
 
module hunt.redis.util.ByteArrayComparator;

// class ByteArrayComparator {
//   private this() {
//     throw new InstantiationError( "Must not instantiate this class" );
//   }

//   static int compare(byte[] val1, byte[] val2) {
//     int len1 = val1.length;
//     int len2 = val2.length;
//     int lmin = Math.min(len1, len2);

//     for (int i = 0; i < lmin; i++) {
//       byte b1 = val1[i];
//       byte b2 = val2[i];
//       if(b1 < b2) return -1;
//       if(b1 > b2) return 1;
//     }

//     if(len1 < len2) return -1;
//     if(len1 > len2) return 1;
//     return 0;
//   }
// }
