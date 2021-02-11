import math { sqrt, pow, round }


struct Vec3 {
	mut:
		x f64
		y f64
		z f64
}

struct Ray {
	mut:
		startpos Vec3
		direction Vec3
}

fn de_sphere(point Vec3, sphere_pos Vec3, sphere_radius f64) f64 {
	return sqrt(
		(sphere_pos.x-point.x) * (sphere_pos.x-point.x) +
		(sphere_pos.y-point.y) * (sphere_pos.y-point.y) +
		(sphere_pos.z-point.z) * (sphere_pos.z-point.z)
	) - sphere_radius
}

fn de_plane(point Vec3, height f64) f64 {
	return point.y - height
}

fn de(point Vec3) f64 {
	s := de_sphere(point, Vec3{0, 0, 0}, 1)
	p := de_plane(point, -1)
	return if s < p { s } else { p }
}

fn dot(a Vec3, b Vec3) f64 {
	return a.x * b.x + a.y * b.y + a.z * b.z
}

fn get_normal(point Vec3) Vec3 {
	// Constant since globals and #define don't exist
	normal_offset := 0.01

	dist := de(point)
	mut normal := Vec3{
		dist - de(Vec3{point.x - normal_offset, point.y, point.z}),
		dist - de(Vec3{point.x, point.y - normal_offset, point.z}),
		dist - de(Vec3{point.x, point.y, point.z - normal_offset})
	}

	len := sqrt(
		(normal.x) * (normal.x) +
		(normal.y) * (normal.y) +
		(normal.z) * (normal.z)
	)
	if len == 0 { return Vec3{0, 0, 0} }
	normal.x /= len
	normal.y /= len
	normal.z /= len
	return normal
}

fn raymarch(mut ray &Ray) int {
	// Constants since globals and #define don't exist
	max_itters := 100
	min_dist := 0.001

	for i in 0 .. max_itters {
		dist := de(ray.startpos)
		if dist <= min_dist { return i }
		ray.startpos.x += ray.direction.x * dist
		ray.startpos.y += ray.direction.y * dist
		ray.startpos.z += ray.direction.z * dist
	}
	return max_itters
}

fn max(a f64, b f64) f64 {
	if a > b { return a }
	return b
}

fn main() {
	// Constants since globals and #define don't exist
	res_x := 50
	res_y := 23
	ao_base := 1.02
	chars := [' ', '.', '-', '*', 'o', '0', 'X']

	mut ray := &Ray{}
	for y_ in 1 .. (res_y + 1) {
		y := res_y - y_
		for x in 0 .. res_x {
			u := f64(x) / f64(res_x - 1) * 2 - 1
			v := f64(y) / f64(res_y - 1) * 2 - 1

			mut dir := Vec3{u, v, -1}
			len := sqrt(
				(dir.x) * (dir.x) +
				(dir.y) * (dir.y) +
				(dir.z) * (dir.z)
			)
			dir.x /= len
			dir.y /= len
			dir.z /= len

			ray.direction = dir
			ray.startpos = Vec3{0, 0, 2}

			iterations := raymarch(mut ray)

			ao := pow(ao_base, -iterations)

			normal := get_normal(ray.startpos)
			light := max(0, dot(normal, Vec3{0.5773502691896258, 0.5773502691896258, 0.5773502691896258}))
			//light := 1
			color := ao * light
			print(chars[int(round(color * 6))])
		}
		print("\n")
	}
}