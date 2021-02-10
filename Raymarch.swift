import Foundation

let MAX_ITTERS = 100
let MIN_DIST = 0.001
let NORMAL_OFFSET = 0.01
let AO_BASE = 1.02
let RES_X = 50
let RES_Y = 23


struct vec3 {
	var x = 0.0
	var y = 0.0
	var z = 0.0
}

struct ray {
	var startpos = vec3()
	var direction = vec3()
}

func DE_Sphere(_ point: vec3, _ sphere_pos: vec3, _ sphere_radius: Double) -> Double {
	return ((sphere_pos.x-point.x)*(sphere_pos.x-point.x)+(sphere_pos.y-point.y)*(sphere_pos.y-point.y)+(sphere_pos.z-point.z)*(sphere_pos.z-point.z)).squareRoot() - sphere_radius
}

func DE_Plane(_ point: vec3, _ height: Double) -> Double {
	return point.y - height
}

func DE(_ point: vec3) -> Double {
	let sphere1 = vec3(x: 0, y: 0, z: 0)
	let s = DE_Sphere(point, sphere1, 1)
	let p = DE_Plane(point, -1)
	return s < p ? s : p
}

func dot(_ a: vec3, _ b: vec3) -> Double {
	return a.x * b.x + a.y * b.y + a.z * b.z
}

func getNormal(_ point: vec3) -> vec3 {
	let dist = DE(point)
	var n = vec3(
		x: dist - DE(vec3(x: point.x - NORMAL_OFFSET, y: point.y, z: point.z)),
		y: dist - DE(vec3(x: point.x, y: point.y - NORMAL_OFFSET, z: point.z)),
		z: dist - DE(vec3(x: point.x, y: point.y, z: point.z - NORMAL_OFFSET))
	)

	let len = ((n.x) * (n.x) + (n.y) * (n.y) + (n.z) * (n.z)).squareRoot()
	if (len == 0) { return vec3(x: 0, y: 0, z: 0) }
	n.x /= len
	n.y /= len
	n.z /= len
	return n
}

struct raymarchResult {
	var outRay = ray()
	var iterationCount = 0
	var result = false
}

func raymarch(_ rayV: ray) -> raymarchResult {
	var result = raymarchResult()
	result.outRay = rayV
	for i in 0..<MAX_ITTERS {
		let dist = DE(result.outRay.startpos)
		result.iterationCount = i
		if (dist <= MIN_DIST) {
			result.result = true
			return result
		}
		result.outRay.startpos.x += result.outRay.direction.x * dist
		result.outRay.startpos.y += result.outRay.direction.y * dist
		result.outRay.startpos.z += result.outRay.direction.z * dist
	}
	result.result = false
	return result
}

let indexx = [" ", ".", "-", "*", "o", "0", "X"]

func main() {
	var rayV = ray()
	for y in (0...RES_Y).reversed() {
		for x in 0..<RES_X {
			var u = Double(x) / Double(RES_X - 1)
			var v = Double(y) / Double(RES_Y - 1)

			u = u * 2 - 1
			v = v * 2 - 1

			var dir = vec3(x: u, y: v, z: -1)
			let len = ((dir.x) * (dir.x) + (dir.y) * (dir.y) + (dir.z) * (dir.z)).squareRoot()
			dir.x /= len
			dir.y /= len
			dir.z /= len

			rayV.direction = dir
			rayV.startpos = vec3(x: 0, y: 0, z: 2)

			let ress = raymarch(rayV)
			let iterations = ress.iterationCount
			rayV = ress.outRay

			let n = getNormal(rayV.startpos)

			let ao = pow(AO_BASE, Double(-iterations))

			var light = dot(n, vec3(x: 0.5773502691896258, y: 0.5773502691896258, z: 0.5773502691896258))
			if (light < 0) { light = 0 }

			var color: Double = ao * light * 6
			color.round()
			print(indexx[Int(color)], terminator:"")
		}
		print()
	}
}

main()