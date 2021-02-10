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

func length(_ a: SIMD3<Double>) -> Double {
	return (a*a).sum().squareRoot()
}

func distance(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
	return length(a - b)
}

func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
	return (a * b).sum()
}

struct ray {
	var startpos = SIMD3<Double>()
	var direction = SIMD3<Double>()
}

func DE_Sphere(_ point: SIMD3<Double>, _ sphere_pos: SIMD3<Double>, _ sphere_radius: Double) -> Double {
	return distance(point, sphere_pos) - sphere_radius
}

func DE_Plane(_ point: SIMD3<Double>, _ height: Double) -> Double {
	return point.y - height
}

func DE(_ point: SIMD3<Double>) -> Double {
	let sphere1 = SIMD3<Double>(0, 0, 0)
	let s = DE_Sphere(point, sphere1, 1)
	let p = DE_Plane(point, -1)
	return s < p ? s : p
}

func dot(_ a: vec3, _ b: vec3) -> Double {
	return a.x * b.x + a.y * b.y + a.z * b.z
}

func getNormal(_ point: SIMD3<Double>) -> SIMD3<Double> {
	let dist = DE(point)
	var n = SIMD3<Double>(
		dist - DE(point + SIMD3<Double>(NORMAL_OFFSET, 0, 0)),
		dist - DE(point + SIMD3<Double>(0, NORMAL_OFFSET, 0)),
		dist - DE(point + SIMD3<Double>(0, 0, NORMAL_OFFSET))
	)

	let len = length(n)
	if (len == 0) { return SIMD3<Double>(0, 0, 0) }
	return n / len
}

struct raymarchResult {
	var outRay = ray()
	var iterationCount: Int = 0
}

func raymarch(_ rayV: ray) -> raymarchResult {
	var result = raymarchResult()
	result.outRay = rayV
	for i in 0..<MAX_ITTERS {
		let dist = DE(result.outRay.startpos)
		result.iterationCount = i
		if (dist <= MIN_DIST) {
			return result
		}
		result.outRay.startpos += result.outRay.direction * dist
	}
	return result
}

let indexx = [" ", ".", "-", "*", "o", "0", "X"]

func main() {
	var rayV = ray()
	for y in (0...RES_Y).reversed() {
		for x in 0..<RES_X {
			var u = Double(x) / Double(RES_X - 1) * 2 - 1
			var v = Double(y) / Double(RES_Y - 1) * 2 - 1

			var dir = SIMD3<Double>(u, v, -1)
			let len = length(dir)
			dir /= len

			rayV.direction = dir
			rayV.startpos = SIMD3<Double>(0, 0, 2)

			let ress = raymarch(rayV)
			let iterations = ress.iterationCount
			rayV = ress.outRay

			let n = getNormal(rayV.startpos)

			let ao = pow(AO_BASE, Double(-iterations))

			var light = dot(n, SIMD3<Double>(0.5773502691896258, 0.5773502691896258, 0.5773502691896258))
			if (light < 0) { light = 0 }

			var color: Double = ao * light * 6
			color.round()
			print(indexx[Int(color)], terminator:"")
		}
		print()
	}
}

main()