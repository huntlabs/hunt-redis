module hunt.redis.params.MigrateParams;

public class MigrateParams : Params {

  private enum string COPY = "COPY";
  private enum string REPLACE = "REPLACE";
  private enum string AUTH = "AUTH";

  public MigrateParams() {
  }

  public static MigrateParams migrateParams() {
    return new MigrateParams();
  }

  public MigrateParams copy() {
    addParam(COPY);
    return this;
  }

  public MigrateParams replace() {
    addParam(REPLACE);
    return this;
  }
  
  public MigrateParams auth(String password) {
    addParam(AUTH, password);
    return this;
  }
}
