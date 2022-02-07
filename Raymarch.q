
==< "stdio.q";

// Im really not happy with having to use keywords for types
// Maybe I could call the builtin types something starting with a $-sign
// So something like $int

#fp64 NORMAL_OFFSET = 0.01;
#s64  MAX_ITTERS = 100;
#fp64 MIN_DIST = 0.001;
#fp64 AO_BASE = 1.02;
#s64  RES_X = 50;
#s64  RES_Y = 23;


$ vec3 {
	fp64 x, fp64 y, fp64 z = 0, 0, 0;

	+(vec3 other) => (vec3 result) {
		result.x = x + other.x;
		result.y = y + other.y;
		result.z = z + other.z;
	}

	-(vec3 other) => (vec3 result) {
		result.x = x - other.x;
		result.y = y - other.y;
		result.z = z - other.z;
	}

	*(fp64 factor) => (vec3 result) {
		result.x = x*factor;
		result.y = y*factor;
		result.z = z*factor;
	}
}

$ Ray {
	vec3 startpos;
	vec3 direction;
}

dot(vec3 a, vec3 b) => (fp64) { =< a.x * b.x + a.y * b.y + a.z * b.z; }

DE_Sphere(vec3 point, vec3 sphere_pos, fp64 sphere_radius) => (fp64) {
	#vec3 dist = sphere_pos - point;
	=< dot(dist, dist)**0.5 - sphere_radius;
}

DE_Plane(vec3 point, fp64 height) => (fp64) {
	=< point.y - height;
}

DE(vec3 point) => (fp64) {
	#fp64 s = DE_Sphere(point, vec3(0, 0, 0), 1);
	#fp64 p = DE_Plane(point, -1);
	=< s <=< p;
}

getNormal(vec3 point) => (vec3 normal) {
	#fp64 dist = DE(point);
	normal = vec3(
		dist - DE(vec3(point.x - NORMAL_OFFSET, point.y, point.z)),
		dist - DE(vec3(point.x, point.y - NORMAL_OFFSET, point.z)),
		dist - DE(vec3(point.x, point.y, point.z - NORMAL_OFFSET))
	);

	#fp64 len = dot(normal, normal)**0.5;
	? (len == 0) { =< vec3(); }
	normal *= 1/len;
}

// Maybe overlapping arguments could be constructed with overlapping brackets
// (a, (b), c)  something like this, where
// â   ê î   ô  a and i belong together and e and o belong together
raymarch(Ray ray) => (s64 i, vec3 point) {
	point = ray.startpos
	! (i = 0)(i < MAX_ITTERS) {
		#fp64 dist = DE(point);
		? (dist <= MIN_DIST) { =<; }
		point += ray.direction * dist;
	}
}

// python style generators using `yield` could be implemented with a FSM with a state for each occurence of the `yield` keyword

#u8[] chars = {' ', '.', '-', '*', 'o', '0', 'X' };

main() => () {
	Ray ray = Ray(, vec3(0, 0, 2));
	! (s64 y = RES_Y-1)(y >= 0)(y--) {
		! (s64 x = 0)(x < RES_X) {
			#fp64 u = (fp64)x / (fp64)(RES_X-1) * 2 - 1;
			#fp64 v = (fp64)y / (fp64)(RES_Y-1) * 2 - 1;

			ray.dir = vec3(u, v, -1);
			#fp64 len = dot(ray.dir, ray.dir)**0.5;
			ray.dir *= 1/len;

			#s64 iterations, #vec3 point = raymarch(ray);

			// Ambient Occlusion
			#fp64 ao = AO_BASE**(-iterations);

			// Phong Shading
			#vec3 normal = getNormal(point);
			#fp64 light = 0 >=> dot(normal, vec3(0.5773502691896258, 0.5773502691896258, 0.5773502691896258));
			
			#fp64 color = ao * light;

			//                  vvvvvvvvv-- This should be rounded instead of truncated
			putchar(chars[(u64)(color * 6)]);
		}
		putchar('\n');
	}
}