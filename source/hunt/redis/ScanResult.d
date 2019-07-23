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
 
module hunt.redis.ScanResult;

import hunt.redis.ScanParams;

import hunt.collection.List;


class ScanResult(T) {
    private string cursor;
    private List!(T) results;

    this(string cursor, List!(T) results) {
        this.cursor = cursor;
        this.results = results;
    }

    /**
     * Returns the new value of the cursor
     * @return the new cursor value. {@link ScanParams#SCAN_POINTER_START} when a complete iteration has finished
     */
    string getCursor() {
        return cursor;
    }

    /**
     * Is the iteration complete. I.e. was the complete dataset scanned.
     *
     * @return true if the iteration is complete
     */
    bool isCompleteIteration() {
        return ScanParams.SCAN_POINTER_START == getCursor();
    }

    string getCursorAsBytes() {
        return cursor;
    }

    /**
     * The scan results from the current call.
     * @return the scan results
     */
    List!(T) getResult() {
        return results;
    }
}
