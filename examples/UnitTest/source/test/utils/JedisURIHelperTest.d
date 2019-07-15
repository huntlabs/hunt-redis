module test.utils.JedisURIHelperTest;

import hunt.Assert;
import hunt.collection;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;
import hunt.util.UnitTest;

import hunt.net.util.HttpURI;

alias URI = HttpURI;

import hunt.redis.util.JedisURIHelper;


class JedisURIHelperTest {

  @Test
  void shouldGetPasswordFromURIWithCredentials() {
    URI uri = new URI("redis://user:password@host:9000/0");
    assertEquals("password", JedisURIHelper.getPassword(uri));
  }

  @Test
  void shouldReturnNullIfURIDoesNotHaveCredentials() {
    URI uri = new URI("redis://host:9000/0");
    assertNull(JedisURIHelper.getPassword(uri));
  }

  @Test
  void shouldGetDbFromURIWithCredentials() {
    URI uri = new URI("redis://user:password@host:9000/3");
    assertEquals(3, JedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldGetDbFromURIWithoutCredentials() {
    URI uri = new URI("redis://host:9000/4");
    assertEquals(4, JedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldGetDefaultDbFromURIIfNoDbWasSpecified() {
    URI uri = new URI("redis://host:9000");
    assertEquals(0, JedisURIHelper.getDBIndex(uri));
  }

  @Test
  void shouldValidateInvalidURIs() {
    assertFalse(JedisURIHelper.isValid(new URI("host:9000")));
    assertFalse(JedisURIHelper.isValid(new URI("user:password@host:9000/0")));
    assertFalse(JedisURIHelper.isValid(new URI("host:9000/0")));
    assertFalse(JedisURIHelper.isValid(new URI("redis://host/0")));
  }

}
