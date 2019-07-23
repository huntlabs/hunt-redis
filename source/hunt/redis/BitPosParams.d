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
 
module hunt.redis.BitPosParams;

import hunt.redis.Protocol;

import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

class BitPosParams {
    private List!(const(ubyte)[]) params;

    this() {
        params = new ArrayList!(const(ubyte)[])();
    }

    this(long start) {
        this();
        params.add(Protocol.toByteArray(start));
    }

    this(long start, long end) {
        this(start);

        params.add(Protocol.toByteArray(end));
    }

    Collection!(const(ubyte)[]) getParams() {
        return params;
    }
}
