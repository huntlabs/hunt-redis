module hunt.redis.Tuple;

import hunt.util.ArrayHelper;
// import java.util.Objects;

import hunt.Double;

import hunt.redis.util.ByteArrayComparator;
import hunt.redis.util.SafeEncoder;

class Tuple : Comparable!(Tuple) {
  private byte[] element;
  private Double score;

  this(string element, Double score) {
    this(SafeEncoder.encode(element), score);
  }

  this(byte[] element, Double score) {
    super();
    this.element = element;
    this.score = score;
  }

  override
  size_t toHash() @trusted nothrow {
    int prime = 31;
    int result = 1;
    result = prime * result;
    if (null != element) {
      foreach(byte b ; element) {
        result = prime * result + b;
      }
    }
    long temp = Double.doubleToLongBits(score);
    result = prime * result + cast(int) (temp ^ (temp >>> 32));
    return result;
  }

  override
  bool opEquals(Object obj) {
    if (obj is null) return false;
    if (obj is this) return true;

    Tuple other = cast(Tuple) obj;
    if(other is null)
      return false;
    if (element != other.element) return false;
    return score == other.score;
  }

  override
  int compareTo(Tuple other) {
    return compare(this, other);
  }

  static int compare(Tuple t1, Tuple t2) {
    int compScore = Double.compare(t1.score, t2.score);
    if(compScore != 0) return compScore;

    return ByteArrayComparator.compare(t1.element, t2.element);
  }

  string getElement() {
    if (null != element) {
      return SafeEncoder.encode(element);
    } else {
      return null;
    }
  }

  byte[] getBinaryElement() {
    return element;
  }

  double getScore() {
    return score;
  }

  override
  string toString() {
    return '[' + SafeEncoder.encode(element) + ',' + score + ']';
  }
}
