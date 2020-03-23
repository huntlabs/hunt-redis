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
import hunt.logging.ConsoleLogger;
import hunt.Long;
import hunt.String;
import hunt.redis.util.SafeEncoder;

import std.conv;
import std.concurrency : initOnce;
import std.range;


/**
 * TODO: 
 */
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

    static Builder!(const(ubyte)[]) BYTE_ARRAY() {
        __gshared Builder!(const(ubyte)[]) inst;

        return initOnce!inst(new class Builder!(const(ubyte)[]) {
            override
            const(ubyte)[] build(Object data) {
                if(data is null)
                    return null;

                warning(typeid(data));
                Bytes bytesObj = cast(Bytes)data;
                return cast(const(ubyte)[]) bytesObj.value(); // deleted == 1
            }

            override string toString() {
                return "const(ubyte)[]";
            }
        });
    }

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
                if(data is null) {
                    version(HUNT_DEBUG) warning("data is null");
                    return null;
                }

                Bytes bytesObject = cast(Bytes)data;
                if(bytesObject !is null) {
                    byte[] bytes = bytesObject.value();
                    version(HUNT_REDIS_DEBUG) tracef("value: %s, %(0x%02X, %)", cast(string)bytes, bytes);
                    return cast(string)bytes;
                } else {
                    version(HUNT_DEBUG) warningf("value: %s, type: %s", data.toString(), typeid(data));
                    return data.toString();
                }
            }

            override
            string toString() {
                return "string";
            }
        });
    }

    static Builder!(List!(string)) STRING_LIST() {
        __gshared Builder!(List!(string)) inst;

        return initOnce!inst(new class Builder!(List!(string)) {
            override List!(string) build(Object data) {
                if (data is null) {
                    return null;
                }
                version(HUNT_REDIS_DEBUG) warning(typeid(data));
                List!(Object) l = cast(List!(Object)) data;
                ArrayList!(string) result = new ArrayList!(string)(l.size());
                foreach(Object barray ; l) {
                    Bytes bytes = cast(Bytes)barray;
                    if (bytes is null) {
                        result.add(cast(string)null);
                    } else {
                        result.add(SafeEncoder.encode(cast(ubyte[])bytes.value()));
                    }
                }
                return result;
            }

            override string toString() {
                return "List!(string)";
            }

        });
    }

    static Builder!(Map!(string, string)) STRING_MAP() {
        __gshared Builder!(Map!(string, string)) inst;

        return initOnce!inst(new class Builder!(Map!(string, string)) {
            override
            Map!(string, string) build(Object data) {
                // warning(typeid(data));
                List!(const(ubyte)[]) flatHash = cast(List!(const(ubyte)[])) data;
                Map!(string, string) hash = new HashMap!(string, string)(flatHash.size()/2, 1);
                InputRange!(const(ubyte)[]) iterator = flatHash.iterator();
                while (!iterator.empty()) {
                    const(ubyte)[] first = iterator.front(); iterator.popFront();
                    const(ubyte)[] second = iterator.front(); iterator.popFront();
                    hash.put(SafeEncoder.encode(first), SafeEncoder.encode(second));
                }

                return hash;
            }

            override
            string toString() {
                return "Map!(string, string)";
            }
        });
    }

    static Builder!(Map!(string, string)) PUBSUB_NUMSUB_MAP() {
        __gshared Builder!(Map!(string, string)) inst;
        
        return initOnce!inst(new class Builder!(Map!(string, string)) {

            override
            Map!(string, string) build(Object data) {
                // warning(typeid(data));
                List!(Object) flatHash = cast(List!(Object)) data;
                Map!(string, string) hash = new HashMap!(string, string)(flatHash.size()/2, 1);

                InputRange!(Object) iterator = flatHash.iterator();
                while (!iterator.empty()) {

                    Object firstObj = iterator.front;
                    iterator.popFront();

                    Object secondObj = iterator.front;
                    iterator.popFront();

                    String stringObj = cast(String)firstObj;
                    Long longObj = cast(Long)secondObj;

                    hash.put(cast(string)SafeEncoder.encode(stringObj.value),
                        to!string(longObj.value));
                }

                return hash;
            }

            override
            string toString() {
                return "PUBSUB_NUMSUB_MAP!(string, string)";
            }
        });
    }

    static Builder!(Set!(string)) STRING_SET() {
        __gshared Builder!(Set!(string)) inst;
        
        return initOnce!inst(new class Builder!(Set!(string)) {

            override
            Set!(string) build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();

                // List!(const(ubyte)[]) l = cast(List!(const(ubyte)[])) data;
                // Set!(string) result = new HashSet!(string)(l.size(), 1);
                // foreach(const(ubyte)[] barray ; l) {
                //     if (barray is null) {
                //         result.add(null);
                //     } else {
                //         result.add(SafeEncoder.encode(barray));
                //     }
                // }
                // return result;
                return null;
            }

            override
            string toString() {
                return "Set!(string)";
            }
        });
    }
    
    static Builder!(List!(const(ubyte)[])) BYTE_ARRAY_LIST() {
        __gshared Builder!(List!(const(ubyte)[])) inst;
        return initOnce!inst(new class Builder!(List!(const(ubyte)[])) {
            override
            
            List!(const(ubyte)[]) build(Object data) {
                if (data is null) {
                    return null;
                }

                List!Object lst = cast(List!Object)data;
                if(lst is null) {
                    version(HUNT_DEBUG) warning("lst is null");
                    return null;
                } else {
                     ArrayList!(const(ubyte)[]) result = new ArrayList!(const(ubyte)[])(lst.size());
                     foreach(Object obj; lst) {
                         Bytes bytes = cast(Bytes)obj;
                         if(bytes is null) {
                             result.add(null);
                         } else {
                            result.add(cast(ubyte[])bytes.value);
                         }
                     }
                    return result;
                }                
            }

            override
            string toString() {
                return "List!(const(ubyte)[])";
            }
        });
    }

    static Builder!(Set!(const(ubyte)[])) BYTE_ARRAY_ZSET() {
        __gshared Builder!(Set!(const(ubyte)[])) inst;
        
        return initOnce!inst(new class Builder!(Set!(const(ubyte)[])) {

            override
            Set!(const(ubyte)[]) build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

                // List!(const(ubyte)[]) l = cast(List!(const(ubyte)[])) data;
                // Set!(const(ubyte)[]) result = new LinkedHashSet!(const(ubyte)[])(l);
                // foreach(const(ubyte)[] barray ; l) {
                //     if (barray is null) {
                //         result.add(null);
                //     } else {
                //         result.add(barray);
                //     }
                // }
                // return result;
            }

            override
            string toString() {
                return "ZSet!(const(ubyte)[])";
            }
        });
    }

    static Builder!(Map!(const(ubyte)[], const(ubyte)[])) BYTE_ARRAY_MAP() {
        __gshared Builder!(Map!(const(ubyte)[], const(ubyte)[])) inst;
        
        return initOnce!inst(new class Builder!(Map!(const(ubyte)[], const(ubyte)[])) {

            override
            Map!(const(ubyte)[], const(ubyte)[]) build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

                // Map!(const(ubyte)[], const(ubyte)[]) build(Object data) {
                // List!(const(ubyte)[]) flatHash = (List!(const(ubyte)[])) data;
                // Map!(const(ubyte)[], const(ubyte)[]) hash = new RedisByteHashMap();
                // Iterator!(const(ubyte)[]) iterator = flatHash.iterator();
                // while (iterator.hasNext()) {
                //     hash.put(iterator.next(), iterator.next());
                // }

                // return hash;
            }

            override
            string toString() {
                return "Map!(const(ubyte)[], const(ubyte)[])";
            }
        });
    }


    static Builder!(Set!(string)) STRING_ZSET() {
        __gshared Builder!(Set!(string)) inst;
        
        return initOnce!inst(new class Builder!(Set!(string)) {

            override
            Set!(string) build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

                // List!(const(ubyte)[]) l = (List!(const(ubyte)[])) data;
                // Set!(string) result = new LinkedHashSet!(string)(l.size(), 1);
                // foreach(const(ubyte)[] barray ; l) {
                //     if (barray is null) {
                //         result.add(null);
                //     } else {
                //         result.add(SafeEncoder.encode(barray));
                //     }
                // }
                // return result;
            }

            override
            string toString() {
                return "ZSet!(string)";
            }
        });
    }


    static Builder!(Set!(Tuple)) TUPLE_ZSET() {
        __gshared Builder!(Set!(Tuple)) inst;
        
        return initOnce!inst(new class Builder!(Set!(Tuple)) {

            override
            Set!(Tuple) build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

    //          List!(const(ubyte)[]) l = (List!(const(ubyte)[])) data;
    //          Set!(Tuple) result = new LinkedHashSet!(Tuple)(l.size()/2, 1);
    //          Iterator!(const(ubyte)[]) iterator = l.iterator();
    //          while (iterator.hasNext()) {
    //              result.add(new Tuple(iterator.next(), DOUBLE.build(iterator.next())));
    //          }
    //          return result;
            }

            override
            string toString() {
                return "ZSet!(Tuple)";
            }
        });
    }

    static Builder!(Object) EVAL_RESULT() {
        __gshared Builder!(Object) inst;
        
        return initOnce!inst(new class Builder!(Object) {

            override
            Object build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

    //          if (result instanceof const(ubyte)[]) return SafeEncoder.encode((const(ubyte)[]) result);

    //          if (result instanceof List<?>) {
    //              List<?> list = (List<?>) result;
    //              List!(Object) listResult = new ArrayList!(Object)(list.size());
    //              foreach(Object bin ; list) {
    //                  listResult.add(evalResult(bin));
    //              }

    //              return listResult;
    //          }

    //          return result;
            }


            override
            string toString() {
                return "Eval!(Object)";
            }
        });
    }


    static Builder!(Object) EVAL_BINARY_RESULT() {
        __gshared Builder!(Object) inst;
        
        return initOnce!inst(new class Builder!(Object) {

            override
            Object build(Object data) {
                if (data is null) {
                    return null;
                }
                warning(typeid(data));
                implementationMissing();
                return null;

    //          if (result instanceof List<?>) {
    //              List<?> list = (List<?>) result;
    //              List!(Object) listResult = new ArrayList!(Object)(list.size());
    //              foreach(Object bin ; list) {
    //                  listResult.add(evalResult(bin));
    //              }

    //              return listResult;
    //          }

    //          return result;
            }


            override
            string toString() {
                return "Eval!(Object)";
            }
        });
    }

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
        __gshared Builder!(List!(GeoRadiusResponse)) inst;

        return initOnce!inst(new class Builder!(List!(GeoRadiusResponse)) {

            override List!(GeoRadiusResponse) build(Object data) {
                if (data is null) {
                    return null;
                }

                List!(Object) objectList = cast(List!(Object)) data;

                List!(GeoRadiusResponse) responses = new ArrayList!(GeoRadiusResponse)(objectList.size());
                if (objectList.isEmpty()) {
                    return responses;
                }

                List!Object tmp = cast(List!(Object)) objectList.get(0);
                if (tmp !is null) {
                    // list of members with additional informations
                    GeoRadiusResponse resp;
                    foreach(Object obj ; objectList) {
                        List!(Object) informations = cast(List!(Object)) obj;

                        Object tempObj = informations.get(0);
                        Bytes tempData = cast(Bytes)tempObj;
                        if(tempData is null) {
                            warning(typeid(tempObj));
                        }
                        resp = new GeoRadiusResponse(cast(string)tempData.value());

                        int size = informations.size();
                        for (int idx = 1; idx < size; idx++) {
                            Object infoObj = informations.get(idx);
                            List!(Object) coord = cast(List!(Object))infoObj;
                            if (coord !is null) {
                                // coordinate
                                resp.setCoordinate(new GeoCoordinate(DOUBLE.build(coord.get(0)).value(),
                                        DOUBLE.build(coord.get(1)).value()));
                            } else {
                                // distance
                                resp.setDistance(DOUBLE.build(infoObj).value());
                            }
                        }

                        responses.add(resp);
                    }
                } else {
                    // list of members
                    foreach(Object obj ; objectList) {
                        Bytes tempObj = cast(Bytes)obj;
                        if(tempObj is null) {
                            warning(typeid(obj));
                        }
                        responses.add(new GeoRadiusResponse(cast(string)tempObj.value()));
                    }
                }

                return responses;
            }

            override string toString() {
                return "GeoRadiusWithParamsResult";
            }
        });            
    }

    static Builder!(List!(Module)) MODULE_LIST() {
        __gshared Builder!(List!(Module)) inst;

        return initOnce!inst(new class Builder!(List!(Module)) {

            override
            List!(Module) build(Object data) {
                if (data is null) {
                    return null;
                }

                List!(List!(Object)) objectList = cast(List!(List!(Object))) data;

                List!(Module) responses = new ArrayList!(Module)(objectList.size());
                if (objectList.isEmpty()) {
                    return responses;
                }

                foreach(List!(Object) moduleResp; objectList) {
                    Object tempObj1 = moduleResp.get(1);
                    Object tempObj3 = moduleResp.get(3);


                    String strObj = cast(String)tempObj1;
                    if(strObj is null) {
                        warning(typeid(tempObj1));
                        implementationMissing();
                    }

                    Long longObj = cast(Long)tempObj3;
                    if(longObj is null) {
                        warning(typeid(tempObj3));
                        implementationMissing();
                    }

                    Module m = new Module(cast(string)SafeEncoder.encode(strObj.value), 
                            longObj.intValue());
                    responses.add(m);
                }

                return responses;
            }

            override string toString() {
                return "List!(Module)";
            }
        });
    }

    static Builder!(List!(Long)) LONG_LIST() {
        __gshared Builder!(List!(Long)) inst;

        return initOnce!inst(new class Builder!(List!(Long)) {
            override List!(Long) build(Object data) {
                if (data is null) {
                    return null;
                }

                version(HUNT_REDIS_DEBUG) warning(typeid(data));
                return cast(List!(Long)) data;
            }

            override string toString() {
                return "List!(Long)";
            }

        });
    }

    static Builder!(StreamEntryID) STREAM_ENTRY_ID() {
        __gshared Builder!(StreamEntryID) inst;

        return initOnce!inst(new class Builder!(StreamEntryID) {
            override StreamEntryID build(Object data) {
                if (data is null) {
                    return null;
                }

                String strObj = cast(String)data;
                if(strObj is null) {
                    warning(typeid(data));
                    implementationMissing();
                }

                string id = cast(string)SafeEncoder.encode(strObj.value);
                return new StreamEntryID(id);
            }

            override string toString() {
                return "StreamEntryID";
            }

        });
    }

    static Builder!(List!(StreamEntry)) STREAM_ENTRY_LIST() {

        __gshared Builder!(List!(StreamEntry)) inst;
        
        return initOnce!inst(new class Builder!(List!(StreamEntry)) {
            override List!(StreamEntry) build(Object data) {
                if (data is null) {
                    return null;
                }

                List!(ArrayList!(Object)) objectList = cast(List!(ArrayList!(Object))) data;

                List!(StreamEntry) responses = new ArrayList!(StreamEntry)(objectList.size()/2);
                if (objectList.isEmpty()) {
                    return responses;
                }

                foreach(ArrayList!(Object) res; objectList) {

                    warning(typeid(res.get(0)));

                    // string entryIdString = SafeEncoder.encode((const(ubyte)[])res.get(0));
                    // StreamEntryID entryID = new StreamEntryID(entryIdString);
                    // List!(const(ubyte)[]) hash = (List!(const(ubyte)[]))res.get(1);
                    
                    // Iterator!(const(ubyte)[]) hashIterator = hash.iterator();
                    // Map!(string, string) map = new HashMap<>(hash.size()/2);
                    // while(hashIterator.hasNext()) {
                    //     map.put(SafeEncoder.encode((const(ubyte)[])hashIterator.next()), SafeEncoder.encode((const(ubyte)[])hashIterator.next()));
                    // }
                    // responses.add(new StreamEntry(entryID, map));
                }

                return responses;
            }

            override string toString() {
                return "List!(StreamEntry)";
            }

        });
    }
    
    static Builder!(List!(StreamPendingEntry)) STREAM_PENDING_ENTRY_LIST() {
        __gshared Builder!(List!(StreamPendingEntry)) inst;

        return initOnce!inst(new class Builder!(List!(StreamPendingEntry)) {
            override List!(StreamPendingEntry) build(Object data) {
                if (data is null) {
                    return null;
                }

                List!(Object) streamsEntries = cast(List!(Object))data;
                List!(StreamPendingEntry) result = new ArrayList!(StreamPendingEntry)(streamsEntries.size());
                
                foreach(Object streamObj ; streamsEntries) {
                    List!(Object) stream = cast(List!(Object))streamObj;
                    warning(typeid(stream.get(0)));
                    // string id = SafeEncoder.encode((const(ubyte)[])stream.get(0));
                    // string consumerName = SafeEncoder.encode((const(ubyte)[])stream.get(1));
                    // long idleTime = BuilderFactory.LONG.build(stream.get(2));      
                    // long deliveredTimes = BuilderFactory.LONG.build(stream.get(3));
                    // result.add(new StreamPendingEntry(new StreamEntryID(id), consumerName, idleTime, deliveredTimes));
                }

                return result;
            }

            override string toString() {
                return "List!(StreamPendingEntry)";
            }

        });
    }

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
