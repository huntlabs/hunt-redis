module hunt.redis.params.ClientKillParams;

class ClientKillParams : Params {

  private enum string ID = "ID";
  private enum string TYPE = "TYPE";
  private enum string ADDR = "ADDR";
  private enum string SKIPME = "SKIPME";

  static enum Type {
    NORMAL, MASTER, SLAVE, PUBSUB;
  }

  static enum SkipMe {
    YES, NO;
  }

  ClientKillParams() {
  }

  static ClientKillParams clientKillParams() {
    return new ClientKillParams();
  }

  ClientKillParams id(string clientId) {
    addParam(ID, clientId);
    return this;
  }

  ClientKillParams id(byte[] clientId) {
    addParam(ID, clientId);
    return this;
  }

  ClientKillParams type(Type type) {
    addParam(TYPE, type);
    return this;
  }

  ClientKillParams addr(string ipPort) {
    addParam(ADDR, ipPort);
    return this;
  }

  ClientKillParams addr(byte[] ipPort) {
    addParam(ADDR, ipPort);
    return this;
  }

  ClientKillParams addr(string ip, int port) {
    addParam(ADDR, ip + ':' + port);
    return this;
  }

  ClientKillParams skipMe(SkipMe skipMe) {
    addParam(SKIPME, skipMe);
    return this;
  }

}
