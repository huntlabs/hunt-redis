/*
 * Hunt - A redis client library for D programming language.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
 
module hunt.redis.AbstractClient;

// import hunt.redis.commands.Command;
import hunt.redis.BuilderFactory;
import hunt.redis.Exceptions;
import hunt.redis.Protocol;
import hunt.redis.util.IOUtils;
import hunt.redis.util.RedisInputStream;
import hunt.redis.util.RedisOutputStream;
import hunt.redis.util.SafeEncoder;

import hunt.Byte;
import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.Long;
import hunt.String;
import hunt.util.Common;

// import javax.net.ssl.HostnameVerifier;
// import javax.net.ssl.SSLParameters;
// import javax.net.ssl.SSLSocket;
// import javax.net.ssl.SSLSocketFactory;

import hunt.net;

import hunt.io.TcpStream;
import hunt.stream.Common;
import hunt.stream.TcpInputStream;
import hunt.stream.TcpOutputStream;

import core.sync.condition;
import core.sync.mutex;
import core.time;

import std.array;
import std.format;
import std.socket;


alias Protocol = hunt.redis.Protocol.Protocol;
alias Command = Protocol.Command;
alias ConstUBytes = const(ubyte)[];


/**
 * 
 */
class AbstractClient : Closeable {
    private NetClient _client;
    private Mutex _doneLocker;
    private Condition _doneCondition;

    private enum const(ubyte)[][] EMPTY_ARGS = null;

    private string host = Protocol.DEFAULT_HOST;
    private int port = Protocol.DEFAULT_PORT;
    private RedisOutputStream outputStream;
    private RedisInputStream inputStream;
    private int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
    private int soTimeout = Protocol.DEFAULT_TIMEOUT;
    private bool broken = false;
    private bool ssl;
    // private SSLSocketFactory sslSocketFactory;
    // private SSLParameters sslParameters;
    // private HostnameVerifier hostnameVerifier;

    this() {
        initialize();
    }

    this(string host) {
        this.host = host;
        initialize();
    }

    this(string host, int port) {
        this.host = host;
        this.port = port;
        initialize();
    }

    this(string host, int port, bool ssl) {
        this.host = host;
        this.port = port;
        this.ssl = ssl;
        initialize();
    }



    // this(string host, int port, bool ssl,
    //     SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
    //     HostnameVerifier hostnameVerifier) {
    //   this.host = host;
    //   this.port = port;
    //   this.ssl = ssl;
    //   this.sslSocketFactory = sslSocketFactory;
    //   this.sslParameters = sslParameters;
    //   this.hostnameVerifier = hostnameVerifier;
    // }

    private void initialize() {
        _doneLocker = new Mutex();
        _doneCondition = new Condition(_doneLocker);
    }

    int getConnectionTimeout() {
        return connectionTimeout;
    }
    
    void setConnectionTimeout(int connectionTimeout) {
        this.connectionTimeout = connectionTimeout;
    }

    int getSoTimeout() {
        return soTimeout;
    }

    void setSoTimeout(int soTimeout) {
        this.soTimeout = soTimeout;
    }

    string getHost() {
        return host;
    }

    void setHost(string host) {
        this.host = host;
    }

    int getPort() {
        return port;
    }

    void setPort(int port) {
        this.port = port;
    }

    void connect() {
        if(isConnected())
            return;
        

        if(soTimeout <= 0) {
            soTimeout = Protocol.DEFAULT_TIMEOUT;
        }
        
        Duration idleTimeout = soTimeout.msecs;
        NetClientOptions options = new NetClientOptions();
        options.setConnectTimeout(connectionTimeout.msecs);
        options.setIdleTimeout(idleTimeout);

        _client = NetUtil.createNetClient(options);

        _client.setHandler(new class NetConnectionHandler {

            override void connectionOpened(Connection connection) {
                version (HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
                _doneLocker.lock();
                scope (exit)
                    _doneLocker.unlock();
                
                outputStream = new RedisOutputStream(new TcpOutputStream(connection.getStream()));
                inputStream = new RedisInputStream(new TcpInputStream(connection.getStream(), idleTimeout));  

                _doneCondition.notifyAll();
            }

            override void connectionClosed(Connection connection) {
                version (HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
            }

            override DataHandleStatus messageReceived(Connection connection, Object message) {
                version(HUNT_REDIS_DEBUG) {
                    tracef("message type: %s", typeid(message).name);
                    string str = format("data received: %s", message.toString());
                    tracef(str);
                }
                // if(count< 10) {
                //     connection.encode(new String(str));
                // }
                // count++;

                return DataHandleStatus.Done;
            }

            override void exceptionCaught(Connection connection, Throwable t) {
                version (HUNT_DEBUG) warning(t);
            }

            override void failedOpeningConnection(int sessionId, Throwable t) {
                version (HUNT_DEBUG) warning(t);
                _client.close(); 
            }

            override void failedAcceptingConnection(int sessionId, Throwable t) {
                version (HUNT_DEBUG) warning(t);
            }
        }).connect(host, port);      

        if(connectionTimeout <= 0) {
            connectionTimeout = Protocol.DEFAULT_TIMEOUT;
        }
        
        _doneLocker.lock();
        scope (exit)
            _doneLocker.unlock();
        if(outputStream is null) {
            version (HUNT_DEBUG) {
                infof("Waiting for a connection in %s...", msecs(connectionTimeout));
            }
            _doneCondition.wait(connectionTimeout.msecs);
        }

        if(!isConnected()) {
            string msg = format("Unable to connect to the server in %s.", 
                connectionTimeout.msecs);
            debug warning(msg);
            throw new RedisConnectionException(msg);
        }
    }

    override
    void close() {
        if (isConnected()) _client.close();
    }

    void disconnect() {
        close();
    }

    bool isConnected() {
        return _client !is null && _client.isConnected();
    }

    void setTimeoutInfinite() {
        if (!isConnected()) {
            try {
                connect();
            } catch (SocketException ex) {
                broken = true;
                throw new RedisConnectionException(ex);
            }
        }
    }

    void rollbackTimeout() {
        try {
            // socket.setSoTimeout(soTimeout);
            // implementationMissing(false);
        } catch (SocketException ex) {
            broken = true;
            throw new RedisConnectionException(ex);
        }
    }

    void sendCommand(Command cmd, string[] args...) {
        const(ubyte)[][] bargs = new const(ubyte)[][args.length];
        for (int i = 0; i < args.length; i++) {
            bargs[i] = SafeEncoder.encode(args[i]);
        }
        sendCommand(cmd, bargs);
    }

    void sendCommand(Command cmd) {
        sendCommand(cmd, EMPTY_ARGS);
    }

    void sendCommand(Command cmd, const(ubyte)[][] args...) {
        try {
            connect();
            if(isConnected()) {
                Protocol.sendCommand(outputStream, cmd, args);
            }
        } catch (RedisConnectionException ex) {
            if(inputStream is null) {
                warning("inputStream is null");
            } else {
                /*
                * When client send request which formed by invalid protocol, Redis send back error message
                * before close connection. We try to read it to provide reason of failure.
                */
                try {
                    string errorMessage = Protocol.readErrorLineIfPossible(inputStream);
                    if (errorMessage !is null && errorMessage.length > 0) {
                        ex = new RedisConnectionException(errorMessage, ex.next);
                    }
                } catch (Exception e) {
                    /*
                    * Catch any IOException or RedisConnectionException occurred from InputStream#read and just
                    * ignore. This approach is safe because reading error message is optional and connection
                    * will eventually be closed.
                    */
                   debug warning(e.msg);
                   version(HUNT_REDIS_DEBUG) warning(e);
                }
            }
            // Any other exceptions related to connection?
            broken = true;
            throw ex;
        }
    }

    string getStatusCodeReply() {
        // flush();
        // Object obj = readProtocolWithCheckingBroken();
        // Bytes bytesObj = cast(Bytes)obj;
        // if(bytesObj is null) {
        //     warning("The obj is not a Bytes.");
        //     throw new NullPointerException();
        // }

        // byte[] resp = bytesObj.value();
        // if (resp.empty()) {
        //     return null;
        // } else {
        //     return SafeEncoder.encode(cast(const(ubyte)[])resp);
        // }
        return getBulkReply();
    }

    string getBulkReply() {
        flush();

        Object obj = readProtocolWithCheckingBroken();
        Bytes bytesObj = cast(Bytes)obj;
        if(bytesObj is null) {
            warning("The obj is not a Bytes.");
            throw new NullPointerException();
        }

        byte[] resp = bytesObj.value();
        string r = cast(string)resp;
        version(HUNT_REDIS_DEBUG_MORE) {
            tracef("reply: %s", r);
        }
        
        return r;
        // if (resp.empty()) {
        //     return null;
        // } else {
        //     return SafeEncoder.encode(cast(const(ubyte)[])resp);
        // }
    }

    const(ubyte)[] getBinaryBulkReply() {
        flush();

        Object obj = readProtocolWithCheckingBroken();
        Bytes bytesObj = cast(Bytes)obj;
        if(bytesObj is null) {
            warning("The obj is not a String.");
            throw new NullPointerException();
        }

        return cast(const(ubyte)[])bytesObj.value();
    }

    Long getIntegerReply() {
        flush();
        Object obj = readProtocolWithCheckingBroken();
        if(obj is null) {
            warning("No value");
            return null;
        } else {
            import hunt.Number;
            Long v = cast(Long)obj;
            if(v is null) {
                Number number = cast(Number)obj;
                Bytes bytes = cast(Bytes)obj;
                if(number !is null) {
                    v = new Long(number.longValue());
                    return v;
                } else if(bytes !is null) {
                    warningf("%(%02X %)", bytes.value());
                    // v = new Long(number.longValue());
                }

                warningf("Not a number: %s", typeid(obj));
                return null;
            }
            
            return v;
        }
    }

    List!(string) getMultiBulkReply() {
        flush();

        return BuilderFactory.STRING_LIST.build(readProtocolWithCheckingBroken());
    }
    

    List!(const(ubyte)[]) getBinaryMultiBulkReply() {
        flush();

        return BuilderFactory.BYTE_ARRAY_LIST.build(readProtocolWithCheckingBroken());

        // return cast(List!(const(ubyte)[])) readProtocolWithCheckingBroken();
        // List!Object lst = cast(List!Object)readProtocolWithCheckingBroken();
        // if(lst is null) {
        //     version(HUNT_DEBUG) warning("lst is null");
        //     return null;
        // } else {

        // }
    }

    // deprecated("")
    // List!(Object) getRawObjectMultiBulkReply() {
    //     return getUnflushedObjectMultiBulkReply();
    // }

    
    List!(Object) getUnflushedObjectMultiBulkReply() {
        return cast(List!(Object)) readProtocolWithCheckingBroken();
    }

    List!(Object) getObjectMultiBulkReply() {
        flush();
        return getUnflushedObjectMultiBulkReply();
    }

    
    List!(long) getIntegerMultiBulkReply() {
        flush();
        List!(Long) items = cast(List!(Long)) readProtocolWithCheckingBroken();
        
        List!(long) r = new ArrayList!long();
        foreach(Long v; items) {
            r.add(v.value());
        }

        return r;
    }

    Object getOne() {
        flush();
        return readProtocolWithCheckingBroken();
    }

    bool isBroken() {
        return broken;
    }

    void flush() {
        try {
            outputStream.flush();
        } catch (IOException ex) {
            broken = true;
            throw new RedisConnectionException(ex);
        }
    }

    protected Object readProtocolWithCheckingBroken() {
        if (broken) {
            throw new RedisConnectionException("Attempting to read from a broken connection");
        }

        try {
            Object obj = Protocol.read(inputStream);
            // version(HUNT_DEBUG) trace(typeid(obj));
            return obj;
        } catch (RedisConnectionException exc) {
            broken = true;
            throw exc;
        }
    }

    List!(Object) getMany(int count) {
        flush();
        List!(Object) responses = new ArrayList!(Object)(count);
        for (int i = 0; i < count; i++) {
            try {
                responses.add(readProtocolWithCheckingBroken());
            } catch (RedisDataException e) {
                responses.add(e);
            }
        }
        return responses;
    }
}
