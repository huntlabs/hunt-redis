module hunt.redis.StreamEntryID;

import hunt.Exceptions;
import hunt.util.Common;
import hunt.util.Comparator;

import std.concurrency : initOnce;
import std.conv;

class StreamEntryID : Comparable!(StreamEntryID) { // , Serializable
  

  /**
  * Should be used only with XADD  
  * 
  * <code>
  * XADD mystream * field1 value1 
  * </code>
  */
  static StreamEntryID NEW_ENTRY() {
    __gshared StreamEntryID inst;
    return initOnce!inst(new class StreamEntryID {
        override string toString(){
        return "*";
        }
    });
  } 
  
  
  /**
  * Should be used only with XGROUP CREATE  
  * 
  * <code>
  * XGROUP CREATE mystream consumer-group-name $
  * </code>
  */
  static StreamEntryID LAST_ENTRY() {
    __gshared StreamEntryID inst;
    return initOnce!inst(new class StreamEntryID {
        override string toString(){
        return "$";
        }
    });
  }
  
  /**
   * Should be used only with XREADGROUP
   * <code>
   * XREADGROUP $GroupName $ConsumerName BLOCK 2000 COUNT 10 STREAMS mystream >
   * </code>
   */
  static StreamEntryID UNRECEIVED_ENTRY() {
    __gshared StreamEntryID inst;
    return initOnce!inst(new class StreamEntryID {
        override string toString(){
        return ">";
        }
    });
  }


    
  private long time;
  private long sequence;

  this() {
    this(0, 0L);
  }
  
  this(string id) {
    string[] split = id.split("-");    
    this.time = split[0].to!long;
    this.sequence = split[1].to!long;
  }
  
  this(long time, long sequence) {
    this.time = time;
    this.sequence = sequence;
  }

  override
  string toString() {
    return time ~ "-" ~ sequence;
  }

  override
  bool opEquals(Object obj) {
    if (this is obj) return true;
    if (obj is null) return false;
    StreamEntryID other = cast(StreamEntryID) obj;
    if(other is null) return false;
    return this.time == other.time && this.sequence == other.sequence;
  }
  
  override
  size_t toHash() @trusted nothrow {
    return this.toString().hashOf();
  }

  override
  int opCmp(StreamEntryID other) {
    int timeComapre = compare(this.time, other.time);
    return timeComapre != 0 ? timeComapre : compare(this.sequence, other.sequence);
  }

  long getTime() {
    return time;
  }

  long getSequence() {
    return sequence;
  }
  
//   private void writeObject(java.io.ObjectOutputStream out) {
//     out.writeLong(this.time);
//     out.writeLong(this.sequence);
//   }
  
//   private void readObject(java.io.ObjectInputStream in) {
//     this.time = in.readLong();
//     this.sequence = in.readLong();
//   }
}
