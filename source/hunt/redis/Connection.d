module hunt.redis.Connection;

import hunt.redis.commands.ProtocolCommand;
import hunt.redis.Exceptions;
import hunt.redis.Protocol;
import hunt.redis.util.IOUtils;
import hunt.redis.util.RedisInputStream;
import hunt.redis.util.RedisOutputStream;
import hunt.redis.util.SafeEncoder;

// import java.net.InetSocketAddress;
// import java.net.Socket;
// import java.net.SocketException;
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


import std.socket;

alias Protocol = hunt.redis.Protocol.Protocol;

class Connection : Closeable {

  private enum byte[][] EMPTY_ARGS = null;

  private string host = Protocol.DEFAULT_HOST;
  private int port = Protocol.DEFAULT_PORT;
  private Socket socket;
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
  }

  this(string host) {
    this.host = host;
  }

  this(string host, int port) {
    this.host = host;
    this.port = port;
  }

  this(string host, int port, bool ssl) {
    this.host = host;
    this.port = port;
    this.ssl = ssl;
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

  Socket getSocket() {
    return socket;
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

  void setTimeoutInfinite() {
    try {
      if (!isConnected()) {
        connect();
      }
      socket.setSoTimeout(0);
    } catch (SocketException ex) {
      broken = true;
      throw new RedisConnectionException(ex);
    }
  }

  void rollbackTimeout() {
    try {
      socket.setSoTimeout(soTimeout);
    } catch (SocketException ex) {
      broken = true;
      throw new RedisConnectionException(ex);
    }
  }

  void sendCommand(ProtocolCommand cmd, string[] args...) {
    byte[][] bargs = new byte[args.length][];
    for (int i = 0; i < args.length; i++) {
      bargs[i] = SafeEncoder.encode(args[i]);
    }
    sendCommand(cmd, bargs);
  }

  void sendCommand(ProtocolCommand cmd) {
    sendCommand(cmd, EMPTY_ARGS);
  }

  void sendCommand(ProtocolCommand cmd, byte[] args...) {
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
        if (errorMessage !is null && errorMessage.length() > 0) {
          ex = new RedisConnectionException(errorMessage, ex.getCause());
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
    if (!isConnected()) {
      try {
        socket = new Socket();
        // ->@wjw_add
        socket.setReuseAddress(true);
        socket.setKeepAlive(true); // Will monitor the TCP connection is
        // valid
        socket.setTcpNoDelay(true); // Socket buffer Whetherclosed, to
        // ensure timely delivery of data
        socket.setSoLinger(true, 0); // Control calls close () method,
        // the underlying socket is closed
        // immediately
        // <-@wjw_add

        socket.connect(new InetSocketAddress(host, port), connectionTimeout);
        socket.setSoTimeout(soTimeout);

        if (ssl) {
          if (null == sslSocketFactory) {
            sslSocketFactory = cast(SSLSocketFactory)SSLSocketFactory.getDefault();
          }
          socket = sslSocketFactory.createSocket(socket, host, port, true);
          if (null != sslParameters) {
            (cast(SSLSocket) socket).setSSLParameters(sslParameters);
          }
          if ((null != hostnameVerifier) &&
              (!hostnameVerifier.verify(host, (cast(SSLSocket) socket).getSession()))) {
            string message = string.format(
                "The connection to '%s' failed ssl/tls hostname verification.", host);
            throw new RedisConnectionException(message);
          }
        }

        outputStream = new RedisOutputStream(socket.getOutputStream());
        inputStream = new RedisInputStream(socket.getInputStream());
      } catch (IOException ex) {
        broken = true;
        throw new RedisConnectionException("Failed connecting to host " 
            + host ~ ":" ~ port, ex);
      }
    }
  }

  override
  void close() {
    disconnect();
  }

  void disconnect() {
    if (isConnected()) {
      try {
        outputStream.flush();
        socket.close();
      } catch (IOException ex) {
        broken = true;
        throw new RedisConnectionException(ex);
      } finally {
        IOUtils.closeQuietly(socket);
      }
    }
  }

  bool isConnected() {
    return socket !is null && socket.isBound() && !socket.isClosed() && socket.isConnected()
        && !socket.isInputShutdown() && !socket.isOutputShutdown();
  }

  string getStatusCodeReply() {
    flush();
    byte[] resp = cast(byte[]) readProtocolWithCheckingBroken();
    if (null == resp) {
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
    return cast(byte[]) readProtocolWithCheckingBroken();
  }

  Long getIntegerReply() {
    flush();
    return cast(Long) readProtocolWithCheckingBroken();
  }

  List!(string) getMultiBulkReply() {
    return BuilderFactory.STRING_LIST.build(getBinaryMultiBulkReply());
  }

  List!(byte[]) getBinaryMultiBulkReply() {
    flush();
    return cast(List!(byte[])) readProtocolWithCheckingBroken();
  }

  deprecated("")
  List!(Object) getRawObjectMultiBulkReply() {
    return getUnflushedObjectMultiBulkReply();
  }

  
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

  protected void flush() {
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
