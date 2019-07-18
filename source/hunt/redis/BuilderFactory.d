module hunt.redis.BuilderFactory;

import hunt.redis.Builder;
import hunt.redis.GeoCoordinate;
import hunt.redis.GeoRadiusResponse;
import hunt.redis.Module;
import hunt.redis.StreamEntry;
import hunt.redis.StreamEntryID;
import hunt.redis.StreamPendingEntry;
import hunt.redis.Tuple;

import hunt.collection;
import hunt.Boolean;
import hunt.Byte;
import hunt.Double;
import hunt.Exceptions;
import hunt.Integer;
import hunt.Long;
import hunt.String;

// import hunt.redis.util.RedisByteHashMap;
import hunt.redis.util.SafeEncoder;

import std.conv;
import std.concurrency : initOnce;

class BuilderFactory {
    static Builder!(Double) DOUBLE() {
        __gshared Builder!(Double) inst;
        return initOnce!inst(new class Builder!(Double) {
                override
                Double build(Object data) {
                        string str = STRING.build(data);
                        if (str is null) return null;
                        try {
                                return Double.valueOf(str.to!double);
                        } catch (NumberFormatException e) {
                                if (str == "inf" || str == "+inf") return new Double(Double.POSITIVE_INFINITY);
                                if (str == "-inf") return new Double(Double.NEGATIVE_INFINITY);
                                throw e;
                        }
                }

                override
                string toString() {
                        return "double";
                }
        });
    } 

    static Builder!(Boolean) BOOLEAN() {
        __gshared Builder!(Boolean) inst;
        return initOnce!inst(new class Builder!(Boolean) {
                override
                Boolean build(Object data) {
                        return Boolean.valueOf((cast(Long) data) == 1);
                }

                override
                string toString() {
                        return "bool";
                }
        });
    }

    // static Builder!(byte[]) BYTE_ARRAY() {

    //     implementationMissing();
    //     return null;
    // }
    //  static Builder!(byte[]) BYTE_ARRAY = new Builder!(byte[])() {
    //      override
    //      byte[] build(Object data) {
    //          return ((byte[]) data); // deleted == 1
    //      }

    //      override
    //      string toString() {
    //          return "byte[]";
    //      }
    //  };

    static Builder!(Long) LONG() {
        __gshared Builder!(Long) inst;
        return initOnce!inst(new class Builder!(Long) {
                override
                Long build(Object data) {
                        return cast(Long) data;
                }

                override
                string toString() {
                        return "long";
                }
        });
    }
    
    static Builder!(string) STRING() {
        __gshared Builder!(string) inst;
        return initOnce!inst(new class Builder!(string) {
                override
                string build(Object data) {
                        if(data is null) return null;
                        string bytes = (cast(String)data).value;
                        return bytes;
                }

                override
                string toString() {
                        return "string";
                }
        });
    }

    static Builder!(List!(string)) STRING_LIST() {

        implementationMissing();
        return null;
    }


    // static Builder!(List!(string)) STRING_LIST = new Builder!(List!(string))() {
    //     override
    
    //     List!(string) build(Object data) {
    //         if (null == data) {
    //             return null;
    //         }
    //         List!(byte[]) l = (List!(byte[])) data;
    //         ArrayList!(string) result = new ArrayList!(string)(l.size());
    //         foreach(byte[] barray ; l) {
    //             if (barray is null) {
    //                 result.add(null);
    //             } else {
    //                 result.add(SafeEncoder.encode(barray));
    //             }
    //         }
    //         return result;
    //     }

    //     override
    //     string toString() {
    //         return "List!(string)";
    //     }

    // };

    static Builder!(Map!(string, string)) STRING_MAP() {

        implementationMissing();
        return null;
    }
    // static Builder!(Map!(string, string)) STRING_MAP = new Builder!(Map!(string, string))() {
    //     override
    
    //     Map!(string, string) build(Object data) {
    //         List!(byte[]) flatHash = (List!(byte[])) data;
    //         Map!(string, string) hash = new HashMap!(string, string)(flatHash.size()/2, 1);
    //         Iterator!(byte[]) iterator = flatHash.iterator();
    //         while (iterator.hasNext()) {
    //             hash.put(SafeEncoder.encode(iterator.next()), SafeEncoder.encode(iterator.next()));
    //         }

    //         return hash;
    //     }

    //     override
    //     string toString() {
    //         return "Map!(string, string)";
    //     }

    // };

    static Builder!(Map!(string, string)) PUBSUB_NUMSUB_MAP() {

        implementationMissing();
        return null;
    }
    //  static Builder!(Map!(string, string)) PUBSUB_NUMSUB_MAP = new Builder!(Map!(string, string))() {
    //      override
        
    //      Map!(string, string) build(Object data) {
    //          List!(Object) flatHash = (List!(Object)) data;
    //          Map!(string, string) hash = new HashMap!(string, string)(flatHash.size()/2, 1);
    //          Iterator!(Object) iterator = flatHash.iterator();
    //          while (iterator.hasNext()) {
    //              hash.put(SafeEncoder.encode((byte[]) iterator.next()),
    //                  to!string((Long) iterator.next()));
    //          }

    //          return hash;
    //      }

    //      override
    //      string toString() {
    //          return "PUBSUB_NUMSUB_MAP!(string, string)";
    //      }

    //  };

    static Builder!(Set!(string)) STRING_SET() {

        implementationMissing();
        return null;
    }
    //  static Builder!(Set!(string)) STRING_SET = new Builder!(Set!(string))() {
    //      override
        
    //      Set!(string) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(byte[]) l = (List!(byte[])) data;
    //          Set!(string) result = new HashSet!(string)(l.size(), 1);
    //          foreach(byte[] barray ; l) {
    //              if (barray is null) {
    //                  result.add(null);
    //              } else {
    //                  result.add(SafeEncoder.encode(barray));
    //              }
    //          }
    //          return result;
    //      }

    //      override
    //      string toString() {
    //          return "Set!(string)";
    //      }

    //  };

    static Builder!(List!(string)) BYTE_ARRAY_LIST() {

        implementationMissing();
        return null;
    }
    //  static Builder!(List!(byte[])) BYTE_ARRAY_LIST = new Builder!(List!(byte[]))() {
    //      override
        
    //      List!(byte[]) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(byte[]) l = (List!(byte[])) data;

    //          return l;
    //      }

    //      override
    //      string toString() {
    //          return "List!(byte[])";
    //      }
    //  };

    static Builder!(Set!(string)) BYTE_ARRAY_ZSET() {

        implementationMissing();
        return null;
    }
    //  static Builder!(Set!(byte[])) BYTE_ARRAY_ZSET = new Builder!(Set!(byte[]))() {
    //      override
        
    //      Set!(byte[]) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(byte[]) l = (List!(byte[])) data;
    //          Set!(byte[]) result = new LinkedHashSet!(byte[])(l);
    //          foreach(byte[] barray ; l) {
    //              if (barray is null) {
    //                  result.add(null);
    //              } else {
    //                  result.add(barray);
    //              }
    //          }
    //          return result;
    //      }

    //      override
    //      string toString() {
    //          return "ZSet!(byte[])";
    //      }
    //  };


    static Builder!(Map!(string, string)) BYTE_ARRAY_MAP() {

        implementationMissing();
        return null;
    }

    //  static Builder!(Map!(byte[], byte[])) BYTE_ARRAY_MAP = new Builder!(Map!(byte[], byte[]))() {
    //      override
        
    //      Map!(byte[], byte[]) build(Object data) {
    //          List!(byte[]) flatHash = (List!(byte[])) data;
    //          Map!(byte[], byte[]) hash = new RedisByteHashMap();
    //          Iterator!(byte[]) iterator = flatHash.iterator();
    //          while (iterator.hasNext()) {
    //              hash.put(iterator.next(), iterator.next());
    //          }

    //          return hash;
    //      }

    //      override
    //      string toString() {
    //          return "Map!(byte[], byte[])";
    //      }

    //  };

    static Builder!(Set!(string)) STRING_ZSET() {

        implementationMissing();
        return null;
    }

    //  static Builder!(Set!(string)) STRING_ZSET = new Builder!(Set!(string))() {
    //      override
        
    //      Set!(string) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(byte[]) l = (List!(byte[])) data;
    //          Set!(string) result = new LinkedHashSet!(string)(l.size(), 1);
    //          foreach(byte[] barray ; l) {
    //              if (barray is null) {
    //                  result.add(null);
    //              } else {
    //                  result.add(SafeEncoder.encode(barray));
    //              }
    //          }
    //          return result;
    //      }

    //      override
    //      string toString() {
    //          return "ZSet!(string)";
    //      }

    //  };

    static Builder!(Set!(Tuple)) TUPLE_ZSET() {

        implementationMissing();
        return null;
    }
    //  static Builder!(Set!(Tuple)) TUPLE_ZSET = new Builder!(Set!(Tuple))() {
    //      override
        
    //      Set!(Tuple) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(byte[]) l = (List!(byte[])) data;
    //          Set!(Tuple) result = new LinkedHashSet!(Tuple)(l.size()/2, 1);
    //          Iterator!(byte[]) iterator = l.iterator();
    //          while (iterator.hasNext()) {
    //              result.add(new Tuple(iterator.next(), DOUBLE.build(iterator.next())));
    //          }
    //          return result;
    //      }

    //      override
    //      string toString() {
    //          return "ZSet!(Tuple)";
    //      }

    //  };

    static Builder!(Object) EVAL_RESULT() {

        implementationMissing();
        return null;
    }

    //  static Builder!(Object) EVAL_RESULT = new Builder!(Object)() {

    //      override
    //      Object build(Object data) {
    //          return evalResult(data);
    //      }

    //      override
    //      string toString() {
    //          return "Eval!(Object)";
    //      }

    //      private Object evalResult(Object result) {
    //          if (result instanceof byte[]) return SafeEncoder.encode((byte[]) result);

    //          if (result instanceof List<?>) {
    //              List<?> list = (List<?>) result;
    //              List!(Object) listResult = new ArrayList!(Object)(list.size());
    //              foreach(Object bin ; list) {
    //                  listResult.add(evalResult(bin));
    //              }

    //              return listResult;
    //          }

    //          return result;
    //      }

    //  };

    static Builder!(Object) EVAL_BINARY_RESULT() {

        implementationMissing();
        return null;
    }
    //  static Builder!(Object) EVAL_BINARY_RESULT = new Builder!(Object)() {

    //      override
    //      Object build(Object data) {
    //          return evalResult(data);
    //      }

    //      override
    //      string toString() {
    //          return "Eval!(Object)";
    //      }

    //      private Object evalResult(Object result) {
    //          if (result instanceof List<?>) {
    //              List<?> list = (List<?>) result;
    //              List!(Object) listResult = new ArrayList!(Object)(list.size());
    //              foreach(Object bin ; list) {
    //                  listResult.add(evalResult(bin));
    //              }

    //              return listResult;
    //          }

    //          return result;
    //      }

    //  };

    static Builder!(List!(GeoCoordinate)) GEO_COORDINATE_LIST() {
        __gshared Builder!(List!(GeoCoordinate)) inst;
        return initOnce!inst(new class Builder!(List!(GeoCoordinate)) {
                override List!(GeoCoordinate) build(Object data) {
                        if (data is null) {
                                return null;
                        }
                        return interpretGeoposResult(cast(List!(Object)) data);
                }

                override string toString() {
                        return "List!(GeoCoordinate)";
                }
        });
    } 

    private static List!(GeoCoordinate) interpretGeoposResult(List!(Object) responses) {
        List!(GeoCoordinate) responseCoordinate = new ArrayList!(GeoCoordinate)(responses.size());
        foreach(Object response ; responses) {
                if (response is null) {
                        responseCoordinate.add(null);
                } else {
                        List!(Object) respList = cast(List!(Object)) response;
                        Double first = DOUBLE.build(respList.get(0));
                        Double second = DOUBLE.build(respList.get(1));
                        assert(first !is null && second !is null);
                        GeoCoordinate coord = new GeoCoordinate(first.value(), second.value());
                        responseCoordinate.add(coord);
                }
        }
        return responseCoordinate;
    }

    static Builder!(List!(GeoRadiusResponse)) GEORADIUS_WITH_PARAMS_RESULT() {
            implementationMissing();
            return null;
    }

    //  static Builder!(List!(GeoRadiusResponse)) GEORADIUS_WITH_PARAMS_RESULT = new Builder!(List!(GeoRadiusResponse))() {
    //      override
    //      List!(GeoRadiusResponse) build(Object data) {
    //          if (data is null) {
    //              return null;
    //          }

    //          List!(Object) objectList = (List!(Object)) data;

    //          List!(GeoRadiusResponse) responses = new ArrayList!(GeoRadiusResponse)(objectList.size());
    //          if (objectList.isEmpty()) {
    //              return responses;
    //          }

    //          if (objectList.get(0) instanceof List<?>) {
    //              // list of members with additional informations
    //              GeoRadiusResponse resp;
    //              foreach(Object obj ; objectList) {
    //                  List!(Object) informations = (List!(Object)) obj;

    //                  resp = new GeoRadiusResponse((byte[]) informations.get(0));

    //                  int size = informations.size();
    //                  for (int idx = 1; idx < size; idx++) {
    //                      Object info = informations.get(idx);
    //                      if (info instanceof List<?>) {
    //                          // coordinate
    //                          List!(Object) coord = (List!(Object)) info;

    //                          resp.setCoordinate(new GeoCoordinate(DOUBLE.build(coord.get(0)),
    //                                  DOUBLE.build(coord.get(1))));
    //                      } else {
    //                          // distance
    //                          resp.setDistance(DOUBLE.build(info));
    //                      }
    //                  }

    //                  responses.add(resp);
    //              }
    //          } else {
    //              // list of members
    //              foreach(Object obj ; objectList) {
    //                  responses.add(new GeoRadiusResponse((byte[]) obj));
    //              }
    //          }

    //          return responses;
    //      }

    //      override
    //      string toString() {
    //          return "GeoRadiusWithParamsResult";
    //      }
    //  };


    static Builder!(List!(Module)) MODULE_LIST() {

        implementationMissing();
        return null;
    }
    //  static Builder!(List!(Module)) MODULE_LIST = new Builder!(List!(Module))() {
    //      override
    //      List!(Module) build(Object data) {
    //          if (data is null) {
    //              return null;
    //          }

    //          List!(List!(Object)) objectList = (List!(List!(Object))) data;

    //          List!(Module) responses = new ArrayList!(Module)(objectList.size());
    //          if (objectList.isEmpty()) {
    //              return responses;
    //          }

    //          foreach(List!(Object) moduleResp; objectList) {
    //              Module m = new Module(SafeEncoder.encode((byte[]) moduleResp.get(1)), ((Long) moduleResp.get(3)).intValue());
    //              responses.add(m);
    //          }

    //          return responses;
    //      }

    //      override
    //      string toString() {
    //          return "List!(Module)";
    //      }
    //  };

    static Builder!(List!(Long)) LONG_LIST() {

        implementationMissing();
        return null;
    }

    //  static Builder!(List!(Long)) LONG_LIST = new Builder!(List!(Long))() {
    //      override
        
    //      List!(Long) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          return (List!(Long)) data;
    //      }

    //      override
    //      string toString() {
    //          return "List!(Long)";
    //      }

    //  };

    static Builder!(StreamEntryID) STREAM_ENTRY_ID() {

        implementationMissing();
        return null;
    }
    //  static Builder!(StreamEntryID) STREAM_ENTRY_ID = new Builder!(StreamEntryID)() {
    //      override
        
    //         StreamEntryID build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          string id = SafeEncoder.encode((byte[])data);
    //          return new StreamEntryID(id);
    //      }

    //      override
    //      string toString() {
    //          return "StreamEntryID";
    //      }
    //  };
    

    static Builder!(List!(StreamEntry)) STREAM_ENTRY_LIST() {

        implementationMissing();
        return null;
    }
    //  static Builder!(List!(StreamEntry)) STREAM_ENTRY_LIST = new Builder!(List!(StreamEntry))() {
    //      override
        
    //         List!(StreamEntry) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
    //          List!(ArrayList!(Object)) objectList = (List!(ArrayList!(Object))) data;

    //          List!(StreamEntry) responses = new ArrayList<>(objectList.size()/2);
    //          if (objectList.isEmpty()) {
    //              return responses;
    //          }

    //          foreach(ArrayList!(Object) res ; objectList) {
    //              string entryIdString = SafeEncoder.encode((byte[])res.get(0));
    //              StreamEntryID entryID = new StreamEntryID(entryIdString);
    //              List!(byte[]) hash = (List!(byte[]))res.get(1);
                
    //              Iterator!(byte[]) hashIterator = hash.iterator();
    //              Map!(string, string) map = new HashMap<>(hash.size()/2);
    //              while(hashIterator.hasNext()) {
    //                  map.put(SafeEncoder.encode((byte[])hashIterator.next()), SafeEncoder.encode((byte[])hashIterator.next()));
    //              }
    //              responses.add(new StreamEntry(entryID, map));
    //          }

    //          return responses;
    //      }

    //      override
    //      string toString() {
    //          return "List!(StreamEntry)";
    //      }
    //  };
    
    static Builder!(List!(StreamPendingEntry)) STREAM_PENDING_ENTRY_LIST() {

        implementationMissing();
        return null;
    }
    //  static Builder!(List!(StreamPendingEntry)) STREAM_PENDING_ENTRY_LIST = new Builder!(List!(StreamPendingEntry))() {
    //      override
        
    //         List!(StreamPendingEntry) build(Object data) {
    //          if (null == data) {
    //              return null;
    //          }
            
    //          List!(Object) streamsEntries = (List!(Object))data;
    //          List!(StreamPendingEntry) result = new ArrayList<>(streamsEntries.size());
    //          foreach(Object streamObj ; streamsEntries) {
    //              List!(Object) stream = (List!(Object))streamObj;
    //              string id = SafeEncoder.encode((byte[])stream.get(0));
    //              string consumerName = SafeEncoder.encode((byte[])stream.get(1));
    //              long idleTime = BuilderFactory.LONG.build(stream.get(2));      
    //              long deliveredTimes = BuilderFactory.LONG.build(stream.get(3));
    //              result.add(new StreamPendingEntry(new StreamEntryID(id), consumerName, idleTime, deliveredTimes));
    //          }
    //          return result;
    //      }

    //      override
    //      string toString() {
    //          return "List!(StreamPendingEntry)";
    //      }
    //  };

    static Builder!(Object) OBJECT() {
        __gshared Builder!(Object) inst;
        return initOnce!inst(new class Builder!(Object) {
            override Object build(Object data) {
                return data;
            }

            override string toString() {
                return "Object";
            }
        });
    }

     private this() {
         throw new InstantiationError( "Must not instantiate this class" );
     }

}
