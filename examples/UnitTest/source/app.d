import std.stdio;

import hunt.util.UnitTest;
import hunt.logging.ConsoleLogger;

import test.PoolTest;

import test.utils.JedisURIHelperTest;


void main()
{
	testUnits!(JedisURIHelperTest);
}
