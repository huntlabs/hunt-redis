module hunt.redis.StreamEntry;

import hunt.Exceptions;
import hunt.collection.Map;

class StreamEntry : Serializable{
  
  
  private StreamEntryID id;
  private Map!(string, string) fields;
  
  StreamEntry(StreamEntryID id, Map!(string, string) fields) {
    this.id = id;
    this.fields = fields;
  }
  
  StreamEntryID getID() {
    return id;
  }
  
  Map!(string, string) getFields() {
    return fields;
  }
  
  override
  string toString() {
    return id ~ " " ~ fields;
  }
    
  private void writeObject(java.io.ObjectOutputStream out) throws IOException{
    out.writeUnshared(this.id);
    out.writeUnshared(this.fields);
  }
  
  private void readObject(java.io.ObjectInputStream in) throws IOException, ClassNotFoundException{
    this.id = (StreamEntryID) in.readUnshared();
    this.fields = (Map!(string, string)) in.readUnshared();
  }
}
