module hunt.redis.ScanResult;

import hunt.collection.List;

import hunt.redis.util.SafeEncoder;

class ScanResult!(T) {
  private byte[] cursor;
  private List!(T) results;

  ScanResult(string cursor, List!(T) results) {
    this(SafeEncoder.encode(cursor), results);
  }

  ScanResult(byte[] cursor, List!(T) results) {
    this.cursor = cursor;
    this.results = results;
  }

  /**
   * Returns the new value of the cursor
   * @return the new cursor value. {@link ScanParams#SCAN_POINTER_START} when a complete iteration has finished
   */
  string getCursor() {
    return SafeEncoder.encode(cursor);
  }

  /**
   * Is the iteration complete. I.e. was the complete dataset scanned.
   *
   * @return true if the iteration is complete
   */
  bool isCompleteIteration() {
    return ScanParams.SCAN_POINTER_START == getCursor();
  }

  byte[] getCursorAsBytes() {
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
