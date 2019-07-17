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
import hunt.util.Common;

// import javax.net.ssl.HostnameVerifier;
// import javax.net.ssl.SSLParameters;
// import javax.net.ssl.SSLSocket;
// import javax.net.ssl.SSLSocketFactory;
import hunt.net.NetClient;
import hunt.net.Config;
import hunt.net.NetSocket;
import hunt.net.NetUtil;

import hunt.io.Common;
import hunt.io.TcpStream;
import hunt.io.TcpInputStream;
import hunt.io.TcpOutputStream;

import core.sync.condition;
import core.sync.mutex;
import core.time;

import std.array;
import std.socket;


alias Protocol = hunt.redis.Protocol.Protocol;
alias Command = Protocol.Command;

/**
*/
class AbstractClient : Closeable {
    private NetClient _client;
	private Mutex _doneLocker;
	private Condition _doneCondition;

    private enum byte[][] EMPTY_ARGS = null;

    private string host = Protocol.DEFAULT_HOST;
    private int port = Protocol.DEFAULT_PORT;
    // private Socket socket;
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

    // Socket getSocket() {
    //     return socket;
    // }

    private void initialize() {
		_doneLocker = new Mutex();
		_doneCondition = new Condition(_doneLocker);
    }

    int getConnectionTimeout() {
        return connectionTimeout;
    }

    int getSoTimeout() {
        return soTimeout;
    }

    void setConnectionTimeout(int connectionTimeout) {
        this.connectionTimeout = connectionTimeout;
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
        
        _doneLocker.lock();
        scope (exit)
            _doneLocker.unlock();
            
        _client = NetUtil.createNetClient();

        Config config = new Config();
        config.setConnectionTimeout(connectionTimeout);
        config.setTimeout(soTimeout);
        _client.setConfig(config);
        _client.connectHandler((NetSocket socket) {
            version (HUNT_DEBUG) infof("A connection created with %s:%d", _host, _port);
            // tcpSession.handler(&onDataReceived); 

            outputStream = new RedisOutputStream(new TcpOutputStream(socket.getTcpStream()));
            inputStream = new RedisInputStream(new TcpInputStream(socket.getTcpStream()));  

            _doneCondition.notifyAll();
        });
        _client.connect(port, host);
        
        version (HUNT_DEBUG)
            info("Waiting for a connection...");
        _doneCondition.wait(connectionTimeout.msecs);
    }


    // private void onDataReceived(ByteBuffer buffer) {
    //     version(HUNT_DEBUG) { 
    //         auto data = cast(ubyte[]) buffer.getRemaining();
    //         infof("data received (%d bytes): ", data.length); 
    //         version(HUNT_DEBUG) {
    //             if(data.length<=64)
    //                 infof("%(%02X %)", data[0 .. $]);
    //             else
    //                 infof("%(%02X %) ...", data[0 .. 64]);
    //         }
    //     }
    // }    

    override
    void close() {
        if (isConnected()) {
            _client.close();
        }
    }

    void disconnect() {
        close();
    }

    bool isConnected() {
        return _client !is null && _client.isConnected();
    }


    void setTimeoutInfinite() {
        try {
            if (!isConnected()) {
                connect();
            }
            // socket.setSoTimeout(0);
            implementationMissing(false);
        } catch (SocketException ex) {
            broken = true;
            throw new RedisConnectionException(ex);
        }
    }

    void rollbackTimeout() {
        try {
            // socket.setSoTimeout(soTimeout);
            implementationMissing(false);
        } catch (SocketException ex) {
            broken = true;
            throw new RedisConnectionException(ex);
        }
    }

    void sendCommand(Command cmd, string[] args...) {
        byte[][] bargs = new byte[][args.length];
        for (int i = 0; i < args.length; i++) {
            bargs[i] = SafeEncoder.encode(args[i]);
        }
        sendCommand(cmd, bargs);
    }

    void sendCommand(Command cmd) {
        sendCommand(cmd, EMPTY_ARGS);
    }

    void sendCommand(Command cmd, byte[][] args...) {
        try {
            connect();
            Protocol.sendCommand(outputStream, cmd, args);
        } catch (RedisConnectionException ex) {
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
            }
            // Any other exceptions related to connection?
            broken = true;
            throw ex;
        }
    }

    string getStatusCodeReply() {
        flush();
        Object obj = readProtocolWithCheckingBroken();
        Bytes bytesObj = cast(Bytes)obj;
        if(bytesObj is null) {
            warning("The obj is not a Bytes.");
            throw new NullPointerException();
        }

        byte[] resp = bytesObj.value();
        if (resp.empty()) {
            return null;
        } else {
            return SafeEncoder.encode(resp);
        }
    }

    string getBulkReply() {
        byte[] result = getBinaryBulkReply();
        if (null != result) {
            return SafeEncoder.encode(result);
        } else {
            return null;
        }
    }

    byte[] getBinaryBulkReply() {
        flush();

        Object obj = readProtocolWithCheckingBroken();
        Bytes bytesObj = cast(Bytes)obj;
        if(bytesObj is null) {
            warning("The obj is not a Bytes.");
            throw new NullPointerException();
        }

        byte[] resp = bytesObj.value();

        return resp;
    }

    Long getIntegerReply() {
        flush();
        return cast(Long) readProtocolWithCheckingBroken();
    }

    List!(string) getMultiBulkReply() {
        return BuilderFactory.STRING_LIST.build(cast(Object)getBinaryMultiBulkReply());
    }

    List!(byte[]) getBinaryMultiBulkReply() {
        flush();
        return cast(List!(byte[])) readProtocolWithCheckingBroken();
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

    
    List!(Long) getIntegerMultiBulkReply() {
        flush();
        return cast(List!(Long)) readProtocolWithCheckingBroken();
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
            return Protocol.read(inputStream);
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