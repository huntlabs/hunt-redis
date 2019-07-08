module hunt.redis.params.MigrateParams;

class MigrateParams : Params {

  private enum string COPY = "COPY";
  private enum string REPLACE = "REPLACE";
  private enum string AUTH = "AUTH";

  MigrateParams() {
  }

  static MigrateParams migrateParams() {
    return new MigrateParams();
  }

  MigrateParams copy() {
    addParam(COPY);
    return this;
  }

  MigrateParams replace() {
    addParam(REPLACE);
    return this;
  }
  
  MigrateParams auth(String password) {
    addParam(AUTH, password);
    return this;
  }
}
