module hunt.redis.StreamEntry;

import hunt.Exceptions;
import hunt.collection.Map;

class StreamEntry : Serializable{
  
  
  private StreamEntryID id;
  private Map!(String, String) fields;
  
  StreamEntry(StreamEntryID id, Map!(String, String) fields) {
    this.id = id;
    this.fields = fields;
  }
  
  StreamEntryID getID() {
    return id;
  }
  
  Map!(String, String) getFields() {
    return fields;
  }
  
  override
  String toString() {
    return id + " " + fields;
  }
    
  private void writeObject(java.io.ObjectOutputStream out) throws IOException{
    out.writeUnshared(this.id);
    out.writeUnshared(this.fields);
  }
  
  private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException{
    this.id = (StreamEntryID) in.readUnshared();
    this.fields = (Map!(String, String)) in.readUnshared();
  }
}
