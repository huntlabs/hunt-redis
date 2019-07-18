module test.utils.RedisURIHelperTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.net.util.HttpURI;

alias URI = HttpURI;

import hunt.redis.util.RedisURIHelper;


class JedisURIHelperTest {

  @Test
  void shouldGetPasswordFromURIWithCredentials() {
    URI uri = new URI("redis://user:password@host:9000/0");
    assertEquals("password", RedisURIHelper.getPassword(uri));
  }

  @Test
  void shouldReturnNullIfURIDoesNotHaveCredentials() {
    URI uri = new URI("redis://host:9000/0");
    assertNull(RedisURIHelper.getPassword(uri));
  }

  @Test
  void shouldGetDbFromURIWithCredentials() {
    URI uri = new URI("redis://user:password@host:9000/3");
    assertEquals(3, RedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldGetDbFromURIWithoutCredentials() {
    URI uri = new URI("redis://host:9000/4");
    assertEquals(4, RedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldGetDefaultDbFromURIIfNoDbWasSpecified() {
    URI uri = new URI("redis://host:9000");
    assertEquals(0, RedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldValidateInvalidURIs() {
    assertFalse(RedisURIHelper.isValid(new URI("host:9000")));
    assertFalse(RedisURIHelper.isValid(new URI("user:password@host:9000/0")));
    assertFalse(RedisURIHelper.isValid(new URI("host:9000/0")));
    assertFalse(RedisURIHelper.isValid(new URI("redis://host/0")));
  }

}
