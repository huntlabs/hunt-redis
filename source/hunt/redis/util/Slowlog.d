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
 
module hunt.redis.util.Slowlog;

import hunt.redis.util.SafeEncoder;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.Long;
import hunt.util.StringBuilder;

/**
 * 
 */
class Slowlog {
    private long id;
    private long timeStamp;
    private long executionTime;
    private List!(string) args;
    private enum string COMMA = ",";

    private this(List!(Object) properties) {
        this.id = (cast(Long) properties.get(0)).value();
        this.timeStamp = (cast(Long) properties.get(1)).value();
        this.executionTime = (cast(Long) properties.get(2)).value();

        List!(string) bargs = cast(List!(string)) properties.get(3);
        this.args = new ArrayList!(string)(bargs.size());

        foreach (string barg; bargs) {
            this.args.add(barg);
        }
    }

    static List!(Slowlog) from(List!(Object) nestedMultiBulkReply) {
        List!(Slowlog) logs = new ArrayList!(Slowlog)(nestedMultiBulkReply.size());
        foreach (Object obj; nestedMultiBulkReply) {
            List!(Object) properties = cast(List!(Object)) obj;
            logs.add(new Slowlog(properties));
        }

        return logs;
    }

    long getId() {
        return id;
    }

    long getTimeStamp() {
        return timeStamp;
    }

    long getExecutionTime() {
        return executionTime;
    }

    List!(string) getArgs() {
        return args;
    }

    override string toString() {
        return new StringBuilder().append(id).append(COMMA).append(timeStamp)
            .append(COMMA).append(executionTime).append(COMMA)
            .append((cast(Object) args).toString()).toString();
    }
}
