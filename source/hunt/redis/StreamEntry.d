module hunt.redis.StreamEntry;

import hunt.redis.StreamEntryID;

import hunt.Exceptions;
import hunt.collection.Map;

class StreamEntry { // : Serializable 
  
  
  private StreamEntryID id;
  private Map!(string, string) fields;
  
  this(StreamEntryID id, Map!(string, string) fields) {
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
    return id.toString() ~ " " ~ fields.toString();
  }
    
  // private void writeObject(ObjectOutputStream outputStream) {
  //   outputStream.writeUnshared(this.id);
  //   outputStream.writeUnshared(this.fields);
  // }
  
  // private void readObject(ObjectInputStream inputStream) {
  //   this.id = cast(StreamEntryID) inputStream.readUnshared();
  //   this.fields = cast(Map!(string, string)) inputStream.readUnshared();
  // }
}
