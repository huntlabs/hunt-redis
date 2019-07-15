module hunt.redis.HostAndPort;

import hunt.logging.ConsoleLogger;
import std.socket;

/**
*/
class HostAndPort { // : Serializable 

    __gshared string localhost;

    private string host;
    private int port;

    this(string host, int port) {
        this.host = host;
        this.port = port;
    }

    string getHost() {
        return host;
    }

    int getPort() {
        return port;
    }

    override bool opEquals(Object obj) {
        if (obj is null)
            return false;
        if (obj is this)
            return true;

        HostAndPort hp = cast(HostAndPort) obj;
        if (hp is null)
            return false;

        string thisHost = convertHost(host);
        string hpHost = convertHost(hp.host);
        return port == hp.port && thisHost == hpHost;
    }

    override size_t toHash() @trusted nothrow {
        return 31 * convertHost(host).hashCode() + port;
    }

    override string toString() {
        return host ~ ":" ~ port;
    }

    /**
   * Splits string into host and port parts.
   * string must be in ( host ~ ":" ~ port ) format.
   * Port is optional
   * @param from string to parse
   * @return array of host and port strings
     */
    static string[] extractParts(string from) {
        int idx = from.lastIndexOf(":");
        string host = idx != -1 ? from.substring(0, idx) : from;
        string port = idx != -1 ? from.substring(idx + 1) : "";
        return [host, port];
    }

    /**
   * Creates HostAndPort instance from string.
   * string must be in ( host ~ ":" ~ port ) format.
   * Port is mandatory. Can convert host part.
   * @see #convertHost(string)
   * @param from string to parse
   * @return HostAndPort instance
     */
    static HostAndPort parseString(string from) {
        // NOTE: redis answers with
        // '99aa9999aa9a99aa099aaa990aa99a09aa9a9999 9a09:9a9:a090:9a::99a slave 8c88888888cc08088cc8c8c888c88c8888c88cc8 0 1468251272993 37 connected'
        // for CLUSTER NODES, ASK and MOVED scenarios. That's why there is no possibility to parse address in 'correct' way.
        // Redis should switch to 'bracketized' (RFC 3986) IPv6 address.
        try {
            string[] parts = extractParts(from);
            string host = parts[0];
            int port = Integer.parseInt(parts[1]);
            return new HostAndPort(convertHost(host), port);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(ex);
        }
    }

    static string convertHost(string host) {
        try {
            /*
         * Validate the host name as an IPV4/IPV6 address.
         * If this is an AWS ENDPOINT it will not parse.
         * In that case accept host as is.
         *
         * Costs: If this is an IPV4/6 encoding, e.g. 127.0.0.1 then no DNS lookup
         * is done.  If it is a name then a DNS lookup is done but it is normally cached.
         * Secondarily, this class is typically used to create a connection once
         * at the beginning of processing and then not used again.  So even if the DNS
         * lookup needs to be done then the cost is miniscule.
         */
            InetAddress inetAddress = InetAddress.getByName(host);

            // isLoopbackAddress() handles both IPV4 and IPV6
            if (inetAddress.isLoopbackAddress() || host.equals("0.0.0.0")
                    || host.startsWith("169.254"))
                return getLocalhost();
            else
                return host;
        } catch (Exception e) {
            // Not a valid IP address
            warning("{}.convertHost '" ~ host ~ "' is not a valid IP address. ",
                    HostAndPort.stringof, e);
            return host;
        }
    }

    static void setLocalhost(string localhost) {
        HostAndPort.localhost = localhost;
    }

    /**
   * This method resolves the localhost in a 'lazy manner'.
   *
   * @return localhost
   */
    static string getLocalhost() {
        if (localhost is null) {
            synchronized {
                if (localhost is null) {
                    return localhost = getLocalHostQuietly();
                }
            }
        }
        return localhost;
    }

    static string getLocalHostQuietly() {
        string localAddress;
        try {
            localAddress = InetAddress.getLocalHost().getHostAddress();
        } catch (Exception ex) {
            log.error("{}.getLocalHostQuietly : cant resolve localhost address",
                    HostAndPort.stringof, ex);
            localAddress = "localhost";
        }
        return localAddress;
    }
}
