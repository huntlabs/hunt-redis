module hunt.redis.StreamEntry;

import java.io.IOException;
import hunt.collection.Map;

public class StreamEntry : Serializable{
  
  
  private StreamEntryID id;
  private Map!(String, String) fields;
  
  public StreamEntry(StreamEntryID id, Map!(String, String) fields) {
    this.id = id;
    this.fields = fields;
  }
  
  public StreamEntryID getID() {
    return id;
  }
  
  public Map!(String, String) getFields() {
    return fields;
  }
  
  override
  public String toString() {
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
