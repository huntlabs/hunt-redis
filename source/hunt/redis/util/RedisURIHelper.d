module hunt.redis.util.RedisURIHelper;

public final class RedisURIHelper {

  private enum int DEFAULT_DB = 0;

  private enum string REDIS = "redis";
  private enum string REDISS = "rediss";

  private RedisURIHelper(){
    throw new InstantiationError( "Must not instantiate this class" );
  }

  public static String getPassword(URI uri) {
    String userInfo = uri.getUserInfo();
    if (userInfo != null) {
      return userInfo.split(":", 2)[1];
    }
    return null;
  }

  public static int getDBIndex(URI uri) {
    String[] pathSplit = uri.getPath().split("/", 2);
    if (pathSplit.length > 1) {
      String dbIndexStr = pathSplit[1];
      if (dbIndexStr.isEmpty()) {
        return DEFAULT_DB;
      }
      return Integer.parseInt(dbIndexStr);
    } else {
      return DEFAULT_DB;
    }
  }

  public static boolean isValid(URI uri) {
    if (isEmpty(uri.getScheme()) || isEmpty(uri.getHost()) || uri.getPort() == -1) {
      return false;
    }

    return true;
  }

  private static boolean isEmpty(String value) {
    return value == null || value.trim().length() == 0;
  }

  public static boolean isRedisScheme(URI uri) {
    return REDIS == uri.getScheme();
  }

  public static boolean isRedisSSLScheme(URI uri) {
    return REDISS == uri.getScheme();
  }

}
