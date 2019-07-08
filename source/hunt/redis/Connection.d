module hunt.redis.Connection;

import java.io.Closeable;
import hunt.Exceptions;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketException;
import hunt.collection.ArraryList;
import hunt.collection.List;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLParameters;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

import hunt.redis.commands.ProtocolCommand;
import hunt.redis.exceptions.RedisConnectionException;
import hunt.redis.exceptions.RedisDataException;
import hunt.redis.util.IOUtils;
import hunt.redis.util.RedisInputStream;
import hunt.redis.util.RedisOutputStream;
import hunt.redis.util.SafeEncoder;

class Connection : Closeable {

  private enum byte[][] EMPTY_ARGS = new byte[0][];

  private String host = Protocol.DEFAULT_HOST;
  private int port = Protocol.DEFAULT_PORT;
  private Socket socket;
  private RedisOutputStream outputStream;
  private RedisInputStream inputStream;
  private int connectionTimeout = Protocol.DEFAULT_TIMEOUT;
  private int soTimeout = Protocol.DEFAULT_TIMEOUT;
  private bool broken = false;
  private bool ssl;
  private SSLSocketFactory sslSocketFactory;
  private SSLParameters sslParameters;
  private HostnameVerifier hostnameVerifier;

  Connection() {
  }

  Connection(final String host) {
    this.host = host;
  }

  Connection(final String host, final int port) {
    this.host = host;
    this.port = port;
  }

  Connection(final String host, final int port, final bool ssl) {
    this.host = host;
    this.port = port;
    this.ssl = ssl;
  }

  Connection(final String host, final int port, final bool ssl,
      SSLSocketFactory sslSocketFactory, SSLParameters sslParameters,
      HostnameVerifier hostnameVerifier) {
    this.host = host;
    this.port = port;
    this.ssl = ssl;
    this.sslSocketFactory = sslSocketFactory;
    this.sslParameters = sslParameters;
    this.hostnameVerifier = hostnameVerifier;
  }

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

  void sendCommand(final ProtocolCommand cmd, final String args...) {
    final byte[][] bargs = new byte[args.length][];
    for (int i = 0; i < args.length; i++) {
      bargs[i] = SafeEncoder.encode(args[i]);
    }
    sendCommand(cmd, bargs);
  }

  void sendCommand(final ProtocolCommand cmd) {
    sendCommand(cmd, EMPTY_ARGS);
  }

  void sendCommand(final ProtocolCommand cmd, final byte[] args...) {
    try {
      connect();
      Protocol.sendCommand(outputStream, cmd, args);
    } catch (RedisConnectionException ex) {
      /*
       * When client send request which formed by invalid protocol, Redis send back error message
       * before close connection. We try to read it to provide reason of failure.
       */
      try {
        String errorMessage = Protocol.readErrorLineIfPossible(inputStream);
        if (errorMessage != null && errorMessage.length() > 0) {
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

  String getHost() {
    return host;
  }

  void setHost(final String host) {
    this.host = host;
  }

  int getPort() {
    return port;
  }

  void setPort(final int port) {
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
            sslSocketFactory = (SSLSocketFactory)SSLSocketFactory.getDefault();
          }
          socket = sslSocketFactory.createSocket(socket, host, port, true);
          if (null != sslParameters) {
            ((SSLSocket) socket).setSSLParameters(sslParameters);
          }
          if ((null != hostnameVerifier) &&
              (!hostnameVerifier.verify(host, ((SSLSocket) socket).getSession()))) {
            String message = String.format(
                "The connection to '%s' failed ssl/tls hostname verification.", host);
            throw new RedisConnectionException(message);
          }
        }

        outputStream = new RedisOutputStream(socket.getOutputStream());
        inputStream = new RedisInputStream(socket.getInputStream());
      } catch (IOException ex) {
        broken = true;
        throw new RedisConnectionException("Failed connecting to host " 
            + host + ":" + port, ex);
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
    return socket != null && socket.isBound() && !socket.isClosed() && socket.isConnected()
        && !socket.isInputShutdown() && !socket.isOutputShutdown();
  }

  String getStatusCodeReply() {
    flush();
    final byte[] resp = (byte[]) readProtocolWithCheckingBroken();
    if (null == resp) {
      return null;
    } else {
      return SafeEncoder.encode(resp);
    }
  }

  String getBulkReply() {
    final byte[] result = getBinaryBulkReply();
    if (null != result) {
      return SafeEncoder.encode(result);
    } else {
      return null;
    }
  }

  byte[] getBinaryBulkReply() {
    flush();
    return (byte[]) readProtocolWithCheckingBroken();
  }

  Long getIntegerReply() {
    flush();
    return (Long) readProtocolWithCheckingBroken();
  }

  List!(String) getMultiBulkReply() {
    return BuilderFactory.STRING_LIST.build(getBinaryMultiBulkReply());
  }

  @SuppressWarnings("unchecked")
  List!(byte[]) getBinaryMultiBulkReply() {
    flush();
    return (List!(byte[])) readProtocolWithCheckingBroken();
  }

  deprecated("")
  List!(Object) getRawObjectMultiBulkReply() {
    return getUnflushedObjectMultiBulkReply();
  }

  @SuppressWarnings("unchecked")
  List!(Object) getUnflushedObjectMultiBulkReply() {
    return (List!(Object)) readProtocolWithCheckingBroken();
  }

  List!(Object) getObjectMultiBulkReply() {
    flush();
    return getUnflushedObjectMultiBulkReply();
  }

  @SuppressWarnings("unchecked")
  List!(Long) getIntegerMultiBulkReply() {
    flush();
    return (List!(Long)) readProtocolWithCheckingBroken();
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

  List!(Object) getMany(final int count) {
    flush();
    final List!(Object) responses = new ArrayList!(Object)(count);
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
