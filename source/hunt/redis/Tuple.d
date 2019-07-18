module hunt.redis.Tuple;

import hunt.redis.util.ByteArrayComparator;
import hunt.redis.util.SafeEncoder;

import hunt.util.ArrayHelper;

// import java.util.Objects;

import hunt.Double;
import hunt.util.Common;
import hunt.util.Comparator;

import std.conv;

class Tuple : Comparable!(Tuple) {
    private string element;
    private double score;

    this(string element, double score) {
        this.element = element;
        this.score = score;
    }

    override size_t toHash() @trusted nothrow {
        int prime = 31;
        int result = 1;
        result = prime * result;
        if (null != element) {
            foreach (byte b; element) {
                result = prime * result + b;
            }
        }
        // FIXME: Needing refactor or cleanup -@zxp at 7/17/2019, 11:17:51 AM
        // 
        long temp = cast(long)score; // Double.doubleToLongBits(score);
        result = prime * result + cast(int)(temp ^ (temp >>> 32));
        return result;
    }

    override bool opEquals(Object obj) {
        if (obj is null)
            return false;
        if (obj is this)
            return true;

        Tuple other = cast(Tuple) obj;
        if (other is null)
            return false;
        if (element != other.element)
            return false;
        return score == other.score;
    }

    override int opCmp(Tuple other) {
        return compare(this, other);
    }
    alias opCmp = Object.opCmp;

    static int compare(Tuple t1, Tuple t2) {
        int compScore = hunt.util.Comparator.compare(t1.score, t2.score);
        if (compScore != 0)
            return compScore;

        return t1.element == t2.element;
    }

    string getElement() {
        return element;
    }

    // string getBinaryElement() {
    //     return element;
    // }

    double getScore() {
        return score;
    }

    override string toString() {
        return "[" ~ element ~ "," ~ score.to!string ~ "]";
    }
}
