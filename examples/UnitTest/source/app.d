import std.stdio;

import hunt.util.UnitTest;
import hunt.logging.ConsoleLogger;

import test.HostAndPortTest;
import test.utils.RedisURIHelperTest;


void main()
{

	testUnits!(HostAndPortTest);


	// testUnits!(RedisURIHelperTest);
}
