module hunt.redis.StreamPendingEntry;

import hunt.Exceptions;
import hunt.redis.StreamEntryID;

import std.conv;

class StreamPendingEntry { // : Serializable
  
  
  private StreamEntryID id;
  private string consumerName;
  private long idleTime;
  private long deliveredTimes;
  
  this(StreamEntryID id, string consumerName, long idleTime, long deliveredTimes) {
    this.id = id;
    this.consumerName = consumerName;
    this.idleTime = idleTime;
    this.deliveredTimes = deliveredTimes;
  }
  
  StreamEntryID getID() {
    return id;
  }

  long getIdleTime() {
    return idleTime;
  }

  long getDeliveredTimes() {
    return deliveredTimes;
  }

  string getConsumerName() {
    return consumerName;
  }
  
  override
  string toString() {
    return this.id.toString() ~ " " ~ this.consumerName ~ " idle:" ~ 
        this.idleTime.to!string() ~ " times:" ~ this.deliveredTimes.to!string();
  }
  
  // private void writeObject(java.io.ObjectOutputStream out) {
  //   out.writeUnshared(this.id);
  //   out.writeUTF(this.consumerName);
  //   out.writeLong(idleTime);
  //   out.writeLong(this.deliveredTimes);
  // }
  
  // private void readObject(java.io.ObjectInputStream in) {
  //   this.id = (StreamEntryID) in.readUnshared();
  //   this.consumerName = in.readUTF();
  //   this.idleTime = in.readLong();
  //   this.deliveredTimes = in.readLong();
  // }

}
