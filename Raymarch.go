package main

import "fmt"
import "math"


const MAX_ITTERS int = 100
const MIN_DIST float64 = 0.001
const NORMAL_OFFSET float64 = 0.01
const AO_BASE float64 = 1.02
const RES_X int = 50
const RES_Y int = 23


type vec3 struct {
	x float64
	y float64
	z float64
}

type ray struct {
	startpos vec3
	direction vec3
}

func DE_Sphere(point vec3, sphere_pos vec3, sphere_radius float64) float64 {
	return math.Sqrt(
		(sphere_pos.x-point.x) * (sphere_pos.x-point.x) +
		(sphere_pos.y-point.y) * (sphere_pos.y-point.y) +
		(sphere_pos.z-point.z) * (sphere_pos.z-point.z) ) - sphere_radius
}

func DE_Plane(point vec3, height float64) float64 {
	return point.y - height
}

func DE(point vec3) float64 {
	sphere1 := vec3{0, 0, 0}
	s := DE_Sphere(point, sphere1, 1)
	p := DE_Plane(point, -1)
	return math.Min(s, p)
}

func dot(a vec3, b vec3) float64 {
	return a.x * b.x + a.y * b.y + a.z * b.z
}

func getNormal(point vec3) vec3 {
	dist := DE(point)
	n := vec3{
		dist - DE(vec3{point.x - NORMAL_OFFSET, point.y, point.z}),
		dist - DE(vec3{point.x, point.y - NORMAL_OFFSET, point.z}),
		dist - DE(vec3{point.x, point.y, point.z - NORMAL_OFFSET})}
	len := math.Sqrt(
		(n.x) * (n.x) +
		(n.y) * (n.y) +
		(n.z) * (n.z) )
	if (len == 0) { return vec3{0, 0, 0}}
	n.x /= len
	n.y /= len
	n.z /= len
	return n
}

func raymarch(rayV *ray) int {
	i := 0
	for ; i < MAX_ITTERS; i++ {
		dist := DE((*rayV).startpos)
		if (dist <= MIN_DIST) { return i }
		(*rayV).startpos.x += (*rayV).direction.x * dist;
		(*rayV).startpos.y += (*rayV).direction.y * dist;
		(*rayV).startpos.z += (*rayV).direction.z * dist;
	}
	return i
}

var chars = []rune(" .-*o0X")

func main() {
	var rayV ray
	for y := RES_Y - 1; y >= 0; y-- {
		for x := 0; x < RES_X; x++ {
			u := float64(x) / float64(RES_X - 1) * 2 - 1
			v := float64(y) / float64(RES_Y - 1) * 2 - 1

			dir := vec3{u, v, -1}
			lenn := math.Sqrt(
				(dir.x) * (dir.x) +
				(dir.y) * (dir.y) +
				(dir.z) * (dir.z))
			dir.x /= lenn
			dir.y /= lenn
			dir.z /= lenn

			rayV.direction = dir
			rayV.startpos = vec3{0, 0, 2}

			iterations := raymarch(&rayV)

			n := getNormal(rayV.startpos)

			ao := math.Pow(AO_BASE, float64(-iterations))

			light := dot(n, vec3{0.5773502691896258, 0.5773502691896258, 0.5773502691896258})
			if (light < 0) { light = 0 }

			color := ao * light

			fmt.Printf("%c", chars[int(math.Round(color * float64(len(chars) - 1) ))])
		}
		fmt.Print("\n")
	}
}