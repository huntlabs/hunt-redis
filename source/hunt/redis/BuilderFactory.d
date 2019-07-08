module hunt.redis.BuilderFactory;

import hunt.collection.ArraryList;
import hunt.collection.HashMap;
import hunt.collection.HashSet;
import hunt.collection.Iterator;
import java.util.LinkedHashSet;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;

import hunt.redis.util.RedisByteHashMap;
import hunt.redis.util.SafeEncoder;

final class BuilderFactory {
  static final Builder!(Double) DOUBLE = new Builder!(Double)() {
    override
    Double build(Object data) {
      String string = STRING.build(data);
      if (string == null) return null;
      try {
        return Double.valueOf(string);
      } catch (NumberFormatException e) {
        if (string.equals("inf") || string.equals("+inf")) return Double.POSITIVE_INFINITY;
        if (string.equals("-inf")) return Double.NEGATIVE_INFINITY;
        throw e;
      }
    }

    override
    String toString() {
      return "double";
    }
  };
  static final Builder!(Boolean) BOOLEAN = new Builder!(Boolean)() {
    override
    Boolean build(Object data) {
      return ((Long) data) == 1;
    }

    override
    String toString() {
      return "bool";
    }
  };
  static final Builder!(byte[]) BYTE_ARRAY = new Builder!(byte[])() {
    override
    byte[] build(Object data) {
      return ((byte[]) data); // deleted == 1
    }

    override
    String toString() {
      return "byte[]";
    }
  };

  static final Builder!(Long) LONG = new Builder!(Long)() {
    override
    Long build(Object data) {
      return (Long) data;
    }

    override
    String toString() {
      return "long";
    }

  };
  static final Builder!(String) STRING = new Builder!(String)() {
    override
    String build(Object data) {
      return data == null ? null : SafeEncoder.encode((byte[]) data);
    }

    override
    String toString() {
      return "string";
    }

  };
  static final Builder!(List!(String)) STRING_LIST = new Builder!(List!(String))() {
    override
    @SuppressWarnings("unchecked")
    List!(String) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;
      final ArrayList!(String) result = new ArrayList!(String)(l.size());
      foreach(final byte[] barray ; l) {
        if (barray == null) {
          result.add(null);
        } else {
          result.add(SafeEncoder.encode(barray));
        }
      }
      return result;
    }

    override
    String toString() {
      return "List!(String)";
    }

  };
  static final Builder!(Map!(String, String)) STRING_MAP = new Builder!(Map!(String, String))() {
    override
    @SuppressWarnings("unchecked")
    Map!(String, String) build(Object data) {
      final List!(byte[]) flatHash = (List!(byte[])) data;
      final Map!(String, String) hash = new HashMap!(String, String)(flatHash.size()/2, 1);
      final Iterator!(byte[]) iterator = flatHash.iterator();
      while (iterator.hasNext()) {
        hash.put(SafeEncoder.encode(iterator.next()), SafeEncoder.encode(iterator.next()));
      }

      return hash;
    }

    override
    String toString() {
      return "Map!(String, String)";
    }

  };

  static final Builder!(Map!(String, String)) PUBSUB_NUMSUB_MAP = new Builder!(Map!(String, String))() {
    override
    @SuppressWarnings("unchecked")
    Map!(String, String) build(Object data) {
      final List!(Object) flatHash = (List!(Object)) data;
      final Map!(String, String) hash = new HashMap!(String, String)(flatHash.size()/2, 1);
      final Iterator!(Object) iterator = flatHash.iterator();
      while (iterator.hasNext()) {
        hash.put(SafeEncoder.encode((byte[]) iterator.next()),
          String.valueOf((Long) iterator.next()));
      }

      return hash;
    }

    override
    String toString() {
      return "PUBSUB_NUMSUB_MAP!(String, String)";
    }

  };

  static final Builder!(Set!(String)) STRING_SET = new Builder!(Set!(String))() {
    override
    @SuppressWarnings("unchecked")
    Set!(String) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;
      final Set!(String) result = new HashSet!(String)(l.size(), 1);
      foreach(final byte[] barray ; l) {
        if (barray == null) {
          result.add(null);
        } else {
          result.add(SafeEncoder.encode(barray));
        }
      }
      return result;
    }

    override
    String toString() {
      return "Set!(String)";
    }

  };

  static final Builder!(List!(byte[])) BYTE_ARRAY_LIST = new Builder!(List!(byte[]))() {
    override
    @SuppressWarnings("unchecked")
    List!(byte[]) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;

      return l;
    }

    override
    String toString() {
      return "List!(byte[])";
    }
  };

  static final Builder!(Set!(byte[])) BYTE_ARRAY_ZSET = new Builder!(Set!(byte[]))() {
    override
    @SuppressWarnings("unchecked")
    Set!(byte[]) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;
      final Set!(byte[]) result = new LinkedHashSet!(byte[])(l);
      foreach(final byte[] barray ; l) {
        if (barray == null) {
          result.add(null);
        } else {
          result.add(barray);
        }
      }
      return result;
    }

    override
    String toString() {
      return "ZSet!(byte[])";
    }
  };
  static final Builder!(Map!(byte[], byte[])) BYTE_ARRAY_MAP = new Builder!(Map!(byte[], byte[]))() {
    override
    @SuppressWarnings("unchecked")
    Map!(byte[], byte[]) build(Object data) {
      final List!(byte[]) flatHash = (List!(byte[])) data;
      final Map!(byte[], byte[]) hash = new RedisByteHashMap();
      final Iterator!(byte[]) iterator = flatHash.iterator();
      while (iterator.hasNext()) {
        hash.put(iterator.next(), iterator.next());
      }

      return hash;
    }

    override
    String toString() {
      return "Map!(byte[], byte[])";
    }

  };

  static final Builder!(Set!(String)) STRING_ZSET = new Builder!(Set!(String))() {
    override
    @SuppressWarnings("unchecked")
    Set!(String) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;
      final Set!(String) result = new LinkedHashSet!(String)(l.size(), 1);
      foreach(final byte[] barray ; l) {
        if (barray == null) {
          result.add(null);
        } else {
          result.add(SafeEncoder.encode(barray));
        }
      }
      return result;
    }

    override
    String toString() {
      return "ZSet!(String)";
    }

  };

  static final Builder!(Set!(Tuple)) TUPLE_ZSET = new Builder!(Set!(Tuple))() {
    override
    @SuppressWarnings("unchecked")
    Set!(Tuple) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(byte[]) l = (List!(byte[])) data;
      final Set!(Tuple) result = new LinkedHashSet!(Tuple)(l.size()/2, 1);
      Iterator!(byte[]) iterator = l.iterator();
      while (iterator.hasNext()) {
        result.add(new Tuple(iterator.next(), DOUBLE.build(iterator.next())));
      }
      return result;
    }

    override
    String toString() {
      return "ZSet!(Tuple)";
    }

  };

  static final Builder!(Object) EVAL_RESULT = new Builder!(Object)() {

    override
    Object build(Object data) {
      return evalResult(data);
    }

    override
    String toString() {
      return "Eval!(Object)";
    }

    private Object evalResult(Object result) {
      if (result instanceof byte[]) return SafeEncoder.encode((byte[]) result);

      if (result instanceof List<?>) {
        List<?> list = (List<?>) result;
        List!(Object) listResult = new ArrayList!(Object)(list.size());
        foreach(Object bin ; list) {
          listResult.add(evalResult(bin));
        }

        return listResult;
      }

      return result;
    }

  };

  static final Builder!(Object) EVAL_BINARY_RESULT = new Builder!(Object)() {

    override
    Object build(Object data) {
      return evalResult(data);
    }

    override
    String toString() {
      return "Eval!(Object)";
    }

    private Object evalResult(Object result) {
      if (result instanceof List<?>) {
        List<?> list = (List<?>) result;
        List!(Object) listResult = new ArrayList!(Object)(list.size());
        foreach(Object bin ; list) {
          listResult.add(evalResult(bin));
        }

        return listResult;
      }

      return result;
    }

  };

  static final Builder!(List!(GeoCoordinate)) GEO_COORDINATE_LIST = new Builder!(List!(GeoCoordinate))() {
    override
    List!(GeoCoordinate) build(Object data) {
      if (null == data) {
        return null;
      }
      return interpretGeoposResult((List!(Object)) data);
    }

    override
    String toString() {
      return "List!(GeoCoordinate)";
    }

    private List!(GeoCoordinate) interpretGeoposResult(List!(Object) responses) {
      List!(GeoCoordinate) responseCoordinate = new ArrayList!(GeoCoordinate)(responses.size());
      foreach(Object response ; responses) {
        if (response == null) {
          responseCoordinate.add(null);
        } else {
          List!(Object) respList = (List!(Object)) response;
          GeoCoordinate coord = new GeoCoordinate(DOUBLE.build(respList.get(0)),
              DOUBLE.build(respList.get(1)));
          responseCoordinate.add(coord);
        }
      }
      return responseCoordinate;
    }
  };

  static final Builder!(List!(GeoRadiusResponse)) GEORADIUS_WITH_PARAMS_RESULT = new Builder!(List!(GeoRadiusResponse))() {
    override
    List!(GeoRadiusResponse) build(Object data) {
      if (data == null) {
        return null;
      }

      List!(Object) objectList = (List!(Object)) data;

      List!(GeoRadiusResponse) responses = new ArrayList!(GeoRadiusResponse)(objectList.size());
      if (objectList.isEmpty()) {
        return responses;
      }

      if (objectList.get(0) instanceof List<?>) {
        // list of members with additional informations
        GeoRadiusResponse resp;
        foreach(Object obj ; objectList) {
          List!(Object) informations = (List!(Object)) obj;

          resp = new GeoRadiusResponse((byte[]) informations.get(0));

          int size = informations.size();
          for (int idx = 1; idx < size; idx++) {
            Object info = informations.get(idx);
            if (info instanceof List<?>) {
              // coordinate
              List!(Object) coord = (List!(Object)) info;

              resp.setCoordinate(new GeoCoordinate(DOUBLE.build(coord.get(0)),
                  DOUBLE.build(coord.get(1))));
            } else {
              // distance
              resp.setDistance(DOUBLE.build(info));
            }
          }

          responses.add(resp);
        }
      } else {
        // list of members
        foreach(Object obj ; objectList) {
          responses.add(new GeoRadiusResponse((byte[]) obj));
        }
      }

      return responses;
    }

    override
    String toString() {
      return "GeoRadiusWithParamsResult";
    }
  };


  static final Builder!(List!(Module)) MODULE_LIST = new Builder!(List!(Module))() {
    override
    List!(Module) build(Object data) {
      if (data == null) {
        return null;
      }

      List!(List!(Object)) objectList = (List!(List!(Object))) data;

      List!(Module) responses = new ArrayList!(Module)(objectList.size());
      if (objectList.isEmpty()) {
        return responses;
      }

      foreach(List!(Object) moduleResp; objectList) {
        Module m = new Module(SafeEncoder.encode((byte[]) moduleResp.get(1)), ((Long) moduleResp.get(3)).intValue());
        responses.add(m);
      }

      return responses;
    }

    override
    String toString() {
      return "List!(Module)";
    }
  };

  static final Builder!(List!(Long)) LONG_LIST = new Builder!(List!(Long))() {
    override
    @SuppressWarnings("unchecked")
    List!(Long) build(Object data) {
      if (null == data) {
        return null;
      }
      return (List!(Long)) data;
    }

    override
    String toString() {
      return "List!(Long)";
    }

  };

  static final Builder!(StreamEntryID) STREAM_ENTRY_ID = new Builder!(StreamEntryID)() {
    override
    @SuppressWarnings("unchecked")
     StreamEntryID build(Object data) {
      if (null == data) {
        return null;
      }
      String id = SafeEncoder.encode((byte[])data);
      return new StreamEntryID(id);
    }

    override
    String toString() {
      return "StreamEntryID";
    }
  };
  

  static final Builder!(List!(StreamEntry)) STREAM_ENTRY_LIST = new Builder!(List!(StreamEntry))() {
    override
    @SuppressWarnings("unchecked")
     List!(StreamEntry) build(Object data) {
      if (null == data) {
        return null;
      }
      List!(ArrayList!(Object)) objectList = (List!(ArrayList!(Object))) data;

      List!(StreamEntry) responses = new ArrayList<>(objectList.size()/2);
      if (objectList.isEmpty()) {
        return responses;
      }

      foreach(ArrayList!(Object) res ; objectList) {
        String entryIdString = SafeEncoder.encode((byte[])res.get(0));
        StreamEntryID entryID = new StreamEntryID(entryIdString);
        List!(byte[]) hash = (List!(byte[]))res.get(1);
        
        Iterator!(byte[]) hashIterator = hash.iterator();
        Map!(String, String) map = new HashMap<>(hash.size()/2);
        while(hashIterator.hasNext()) {
          map.put(SafeEncoder.encode((byte[])hashIterator.next()), SafeEncoder.encode((byte[])hashIterator.next()));
        }
        responses.add(new StreamEntry(entryID, map));
      }

      return responses;
    }

    override
    String toString() {
      return "List!(StreamEntry)";
    }
  };
  
  static final Builder!(List!(StreamPendingEntry)) STREAM_PENDING_ENTRY_LIST = new Builder!(List!(StreamPendingEntry))() {
    override
    @SuppressWarnings("unchecked")
     List!(StreamPendingEntry) build(Object data) {
      if (null == data) {
        return null;
      }
      
      List!(Object) streamsEntries = (List!(Object))data;
      List!(StreamPendingEntry) result = new ArrayList<>(streamsEntries.size());
      foreach(Object streamObj ; streamsEntries) {
        List!(Object) stream = (List!(Object))streamObj;
        String id = SafeEncoder.encode((byte[])stream.get(0));
        String consumerName = SafeEncoder.encode((byte[])stream.get(1));
        long idleTime = BuilderFactory.LONG.build(stream.get(2));      
        long deliveredTimes = BuilderFactory.LONG.build(stream.get(3));
        result.add(new StreamPendingEntry(new StreamEntryID(id), consumerName, idleTime, deliveredTimes));
      }
      return result;
    }

    override
    String toString() {
      return "List!(StreamPendingEntry)";
    }
  };

  static final Builder!(Object) OBJECT = new Builder!(Object)() {
    override
    Object build(Object data) {
      return data;
    }
    override
    String toString() {
      return "Object";
    }
  };



  private BuilderFactory() {
    throw new InstantiationError( "Must not instantiate this class" );
  }

}
