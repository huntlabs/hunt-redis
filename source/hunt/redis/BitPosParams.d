module hunt.redis.BitPosParams;

import hunt.redis.Protocol;

import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

class BitPosParams {
    private List!(string) params;

    this() {
        params = new ArrayList!(string)();
    }

    this(long start) {
        this();
        params.add(Protocol.toByteArray(start));
    }

    this(long start, long end) {
        this(start);

        params.add(Protocol.toByteArray(end));
    }

    Collection!(string) getParams() {
        return params;
    }
}
