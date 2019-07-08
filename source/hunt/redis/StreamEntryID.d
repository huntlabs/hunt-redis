module hunt.redis.StreamEntryID;

import hunt.Exceptions;

class StreamEntryID : Comparable!(StreamEntryID), Serializable{
  

  /**
  * Should be used only with XADD  
  * 
  * <code>
  * XADD mystream * field1 value1 
  * </code>
  */
  static final StreamEntryID NEW_ENTRY = new StreamEntryID() {
    
    
    override
    String toString(){
      return "*";
    }
  };
  
  
  /**
  * Should be used only with XGROUP CREATE  
  * 
  * <code>
  * XGROUP CREATE mystream consumer-group-name $
  * </code>
  */
  static final StreamEntryID LAST_ENTRY = new StreamEntryID() {
    
    
    override
    String toString(){
      return "$";
    }
  };
  
  /**
   * Should be used only with XREADGROUP
   * <code>
   * XREADGROUP $GroupName $ConsumerName BLOCK 2000 COUNT 10 STREAMS mystream >
   * </code>
   */
  static final StreamEntryID UNRECEIVED_ENTRY = new StreamEntryID() {
    
    
    override
    String toString(){
      return ">";
    }
  };
    
  private long time;
  private long sequence;

  StreamEntryID() {
    this(0, 0L);
  }
  
  StreamEntryID(String id) {
    String[] split = id.split("-");    
    this.time = Long.parseLong(split[0]);
    this.sequence = Long.parseLong(split[1]);
  }
  
  StreamEntryID(long time, long sequence) {
    this.time = time;
    this.sequence = sequence;
  }

  override
  String toString() {
    return time + "-" + sequence;
  }

  override
  bool equals(Object obj) {
    if (this == obj) return true;
    if (obj == null) return false;
    if (getClass() != obj.getClass()) return false;
    StreamEntryID other = (StreamEntryID) obj;
    return this.time == other.time && this.sequence == other.sequence;
  }
  
  override
  size_t toHash() @trusted nothrow() {
    return this.toString().hashCode();
  }

  override
  int compareTo(StreamEntryID other) {
    int timeComapre = Long.compare(this.time, other.time);
    return timeComapre != 0 ? timeComapre : Long.compare(this.sequence, other.sequence);
  }

  long getTime() {
    return time;
  }

  long getSequence() {
    return sequence;
  }
  
  private void writeObject(java.io.ObjectOutputStream out) throws IOException{
    out.writeLong(this.time);
    out.writeLong(this.sequence);
  }
  
  private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException{
    this.time = in.readLong();
    this.sequence = in.readLong();
  }
}
