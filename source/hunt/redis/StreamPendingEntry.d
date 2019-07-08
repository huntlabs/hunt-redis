module hunt.redis.StreamPendingEntry;

import hunt.Exceptions;

class StreamPendingEntry : Serializable{
  
  
  private StreamEntryID id;
  private String consumerName;
  private long idleTime;
  private long deliveredTimes;
  
  StreamPendingEntry(StreamEntryID id, String consumerName, long idleTime, long deliveredTimes) {
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

  String getConsumerName() {
    return consumerName;
  }
  
  override
  String toString() {
    return this.id + " " + this.consumerName + " idle:" + this.idleTime + " times:" + this.deliveredTimes;
  }
  
  private void writeObject(java.io.ObjectOutputStream out) throws IOException{
    out.writeUnshared(this.id);
    out.writeUTF(this.consumerName);
    out.writeLong(idleTime);
    out.writeLong(this.deliveredTimes);
  }
  
  private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException{
    this.id = (StreamEntryID) in.readUnshared();
    this.consumerName = in.readUTF();
    this.idleTime = in.readLong();
    this.deliveredTimes = in.readLong();
  }

}
