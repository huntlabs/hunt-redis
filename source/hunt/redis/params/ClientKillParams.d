module hunt.redis.params.ClientKillParams;

import hunt.redis.params.Params;

import std.conv;
import std.variant;

class ClientKillParams : Params {

    private enum string ID = "ID";
    private enum string TYPE = "TYPE";
    private enum string ADDR = "ADDR";
    private enum string SKIPME = "SKIPME";

    alias addParam = Params.addParam;

    static enum Type {
        NORMAL,
        MASTER,
        SLAVE,
        PUBSUB
    }

    static enum SkipMe {
        YES,
        NO
    }

    this() {
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
        addParam(TYPE, Variant(type));
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
        addParam(ADDR, ip ~ ":" ~ port.to!string());
        return this;
    }

    ClientKillParams skipMe(SkipMe skipMe) {
        addParam(SKIPME, Variant(skipMe));
        return this;
    }

}
