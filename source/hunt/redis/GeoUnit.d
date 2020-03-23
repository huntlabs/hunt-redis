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
 
module hunt.redis.GeoUnit;

import hunt.redis.util.SafeEncoder;

enum GeoUnit {
	M, KM, MI, FT
}


string toString(GeoUnit value) {
	final switch(value) {
		case GeoUnit.M:
			return "m";

		case GeoUnit.KM:
			return "km";

		case GeoUnit.MI:
			return "mi";

		case GeoUnit.FT:
			return "ft";
	}
}