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
