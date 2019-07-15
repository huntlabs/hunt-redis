module hunt.redis.params.MigrateParams;

import hunt.redis.params.Params;

class MigrateParams : Params {

  private enum string COPY = "COPY";
  private enum string REPLACE = "REPLACE";
  private enum string AUTH = "AUTH";

  this() {
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
  
  MigrateParams auth(string password) {
    addParam(AUTH, password);
    return this;
  }
}
