module hunt.redis.util.Slowlog;

import hunt.collection.ArraryList;
import hunt.collection.List;

class Slowlog {
  private long id;
  private long timeStamp;
  private long executionTime;
  private List!(string) args;
  private enum string COMMA = ",";

  
  private Slowlog(List!(Object) properties) {
    super();
    this.id = (Long) properties.get(0);
    this.timeStamp = (Long) properties.get(1);
    this.executionTime = (Long) properties.get(2);

    List!(byte[]) bargs = (List!(byte[])) properties.get(3);
    this.args = new ArrayList!(string)(bargs.size());

    foreach(byte[] barg ; bargs) {
      this.args.add(SafeEncoder.encode(barg));
    }
  }

  
  static List!(Slowlog) from(List!(Object) nestedMultiBulkReply) {
    List!(Slowlog) logs = new ArrayList!(Slowlog)(nestedMultiBulkReply.size());
    foreach(Object obj ; nestedMultiBulkReply) {
      List!(Object) properties = (List!(Object)) obj;
      logs.add(new Slowlog(properties));
    }

    return logs;
  }
  
  long getId() {
    return id;
  }

  long getTimeStamp() {
    return timeStamp;
  }

  long getExecutionTime() {
    return executionTime;
  }

  List!(string) getArgs() {
    return args;
  }

  override
  string toString() {
    return new StringBuilder().append(id).append(COMMA).append(timeStamp).append(COMMA)
        .append(executionTime).append(COMMA).append(args).toString();
  }
}
