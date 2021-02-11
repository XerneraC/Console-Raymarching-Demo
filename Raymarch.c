#include <stdio.h>
#include <math.h>

#define MAX_ITTERS 100
#define MIN_DIST 0.001
#define NORMAL_OFFSET 0.01
#define AO_BASE 1.02
#define RES_X 50
#define RES_Y 23

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) > (Y)) ? (X) : (Y))

typedef struct _vec3 {
	double x;
	double y;
	double z;
} vec3;

typedef struct _ray {
	vec3 startpos;
	vec3 direction;
} ray;

inline static vec3 vec3_c(double x, double y, double z) {
	vec3 a;
	a.x = x;
	a.y = y;
	a.z = z;
	return a;
}

inline static double DE_Sphere(vec3 point, vec3 sphere_pos, double sphere_radius) {
	return sqrt(
		(sphere_pos.x-point.x) * (sphere_pos.x-point.x) +
		(sphere_pos.y-point.y) * (sphere_pos.y-point.y) +
		(sphere_pos.z-point.z) * (sphere_pos.z-point.z)
	) - sphere_radius;
}

inline static double DE_Plane(vec3 point, double height) {
	return point.y - height;
}

double DE(vec3 point) {
	const double s = DE_Sphere(point, vec3_c(0, 0, 0), 1);
	const double p = DE_Plane(point, -1);
	return MIN(s, p);

}

inline static double dot(vec3 a, vec3 b) {
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

vec3 getNormal(vec3 point) {
	const double dist = DE(point);
	vec3 normal = vec3_c(
		dist - DE(vec3_c(point.x - NORMAL_OFFSET, point.y, point.z)),
		dist - DE(vec3_c(point.x, point.y - NORMAL_OFFSET, point.z)),
		dist - DE(vec3_c(point.x, point.y, point.z - NORMAL_OFFSET))
	);

	double len = sqrt(
		(normal.x) * (normal.x) +
		(normal.y) * (normal.y) +
		(normal.z) * (normal.z)
	);
	if (len == 0) return vec3_c(0, 0, 0);
	normal.x /= len;
	normal.y /= len;
	normal.z /= len;
	return normal;
}

int raymarch(ray* ray) {
	int i;
	for (i = 0; i < MAX_ITTERS; i++) {
		double dist = DE(ray->startpos);
		if (dist <= MIN_DIST) return i;
		ray->startpos.x += ray->direction.x * dist;
		ray->startpos.y += ray->direction.y * dist;
		ray->startpos.z += ray->direction.z * dist;
	}
	return i;
}

char chars[] = { ' ', '.', '-', '*', 'o', '0', 'X' };

int main() {
	ray ray;
	for (int y = RES_Y-1; y >= 0; y--) {
		for (int x = 0; x < RES_X; x++) {
			const double u = (double)x / (double)(RES_X - 1) * 2 - 1;
			const double v = (double)y / (double)(RES_Y - 1) * 2 - 1;

			vec3 dir = vec3_c(u, v, -1);
			const double len = sqrt(
				(dir.x) * (dir.x) +
				(dir.y) * (dir.y) +
				(dir.z) * (dir.z)
			);
			dir.x /= len;
			dir.y /= len;
			dir.z /= len;

			ray.direction = dir;
			ray.startpos = vec3_c(0, 0, 2);

			const int iterations = raymarch(&ray);


			// ambiant occlusion
			const double ao = pow(AO_BASE, -iterations);

			// Phong Shading
			const vec3 normal = getNormal(ray.startpos);
			const double light = MAX(0, dot(normal, vec3_c(0.5773502691896258, 0.5773502691896258, 0.5773502691896258)));

			const double color = ao * light;

			putchar(chars[(int)round(color * 6)]);
		}
		putchar('\n');
	}
}