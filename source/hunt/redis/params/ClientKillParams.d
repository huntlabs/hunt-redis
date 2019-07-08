module hunt.redis.params.ClientKillParams;

public class ClientKillParams : Params {

  private enum string ID = "ID";
  private enum string TYPE = "TYPE";
  private enum string ADDR = "ADDR";
  private enum string SKIPME = "SKIPME";

  public static enum Type {
    NORMAL, MASTER, SLAVE, PUBSUB;
  }

  public static enum SkipMe {
    YES, NO;
  }

  public ClientKillParams() {
  }

  public static ClientKillParams clientKillParams() {
    return new ClientKillParams();
  }

  public ClientKillParams id(String clientId) {
    addParam(ID, clientId);
    return this;
  }

  public ClientKillParams id(byte[] clientId) {
    addParam(ID, clientId);
    return this;
  }

  public ClientKillParams type(Type type) {
    addParam(TYPE, type);
    return this;
  }

  public ClientKillParams addr(String ipPort) {
    addParam(ADDR, ipPort);
    return this;
  }

  public ClientKillParams addr(byte[] ipPort) {
    addParam(ADDR, ipPort);
    return this;
  }

  public ClientKillParams addr(String ip, int port) {
    addParam(ADDR, ip + ':' + port);
    return this;
  }

  public ClientKillParams skipMe(SkipMe skipMe) {
    addParam(SKIPME, skipMe);
    return this;
  }

}
