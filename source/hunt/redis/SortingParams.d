module hunt.redis.SortingParams;

import hunt.redis.Protocol;

import hunt.collection.ArrayList;
import hunt.collection.Collection;
import hunt.collection.Collections;
import hunt.collection.List;

import hunt.redis.util.SafeEncoder;

alias Keyword = Protocol.Keyword;

import std.conv;

/**
 * Builder Class for {@link Redis#sort(string, SortingParams) SORT} Parameters.
 */
class SortingParams {
    private List!(string) params;

    this() {
        params = new ArrayList!(string)();
    }

    /**
     * Sort by weight in keys.
     * <p>
     * Takes a pattern that is used in order to generate the key names of the weights used for
     * sorting. Weight key names are obtained substituting the first occurrence of * with the actual
     * value of the elements on the list.
     * <p>
     * The pattern for a normal key/value pair is "field*" and for a value in a hash
     * "field*-&gt;fieldname".
     * @param pattern
     * @return the SortingParams Object
     */
    SortingParams by(string pattern) {
        return by(SafeEncoder.encode(pattern));
    }

    /**
     * Sort by weight in keys.
     * <p>
     * Takes a pattern that is used in order to generate the key names of the weights used for
     * sorting. Weight key names are obtained substituting the first occurrence of * with the actual
     * value of the elements on the list.
     * <p>
     * The pattern for a normal key/value pair is "field*" and for a value in a hash
     * "field*-&gt;fieldname".
     * @param pattern
     * @return the SortingParams Object
     */
    SortingParams by(string pattern) {
        params.add(Keyword.BY.to!string());
        params.add(pattern);
        return this;
    }

    /**
     * No sorting.
     * <p>
     * This is useful if you want to retrieve a external key (using {@link #get(string...) GET}) but
     * you don't want the sorting overhead.
     * @return the SortingParams Object
     */
    SortingParams nosort() {
        params.add(Keyword.BY.to!string());
        params.add(Keyword.NOSORT.to!string());
        return this;
    }

    Collection!(string) getParams() {
        // return Collections.unmodifiableCollection(params);
        return params;
    }

    /**
     * Get the Sorting in Descending Order.
     * @return the sortingParams Object
     */
    SortingParams desc() {
        params.add(Keyword.DESC.to!string());
        return this;
    }

    /**
     * Get the Sorting in Ascending Order. This is the default order.
     * @return the SortingParams Object
     */
    SortingParams asc() {
        params.add(Keyword.ASC.to!string());
        return this;
    }

    /**
     * Limit the Numbers of returned Elements.
     * @param start is zero based
     * @param count
     * @return the SortingParams Object
     */
    SortingParams limit(int start, int count) {
        params.add(Keyword.LIMIT.to!string());
        params.add(Protocol.toByteArray(start));
        params.add(Protocol.toByteArray(count));
        return this;
    }

    /**
     * Sort lexicographicaly. Note that Redis is utf-8 aware assuming you set the right value for the
     * LC_COLLATE environment variable.
     * @return the SortingParams Object
     */
    SortingParams alpha() {
        params.add(Keyword.ALPHA.to!string());
        return this;
    }

    /**
     * Retrieving external keys from the result of the search.
     * <p>
     * Takes a pattern that is used in order to generate the key names of the result of sorting. The
     * key names are obtained substituting the first occurrence of * with the actual value of the
     * elements on the list.
     * <p>
     * The pattern for a normal key/value pair is "field*" and for a value in a hash
     * "field*-&gt;fieldname".
     * <p>
     * To get the list itself use the char # as pattern.
     * @param patterns
     * @return the SortingParams Object
     */
    SortingParams get(string[] patterns...) {
        foreach(string pattern ; patterns) {
            params.add(Keyword.GET.to!string());
            params.add(SafeEncoder.encode(pattern));
        }
        return this;
    }

    /**
     * Retrieving external keys from the result of the search.
     * <p>
     * Takes a pattern that is used in order to generate the key names of the result of sorting. The
     * key names are obtained substituting the first occurrence of * with the actual value of the
     * elements on the list.
     * <p>
     * The pattern for a normal key/value pair is "field*" and for a value in a hash
     * "field*-&gt;fieldname".
     * <p>
     * To get the list itself use the char # as pattern.
     * @param patterns
     * @return the SortingParams Object
     */
    SortingParams get(string[] patterns...) {
        foreach(string pattern ; patterns) {
            params.add(Keyword.GET.to!string());
            params.add(pattern);
        }
        return this;
    }
}
