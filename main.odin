package main

import fmt "core:fmt"
import math "core:math"

vec3 :: [3]f64

vec3_length :: proc(v: vec3) -> f64 {
	return math.sqrt(vec3_length_squared(v))
}

vec3_length_squared :: proc(v: vec3) -> f64 {
	product := v * v
	return product.x + product.y + product.z
}

vec3_dot :: proc(u, v: vec3) -> f64 {
	product := u * v
	return product.x + product.y + product.z
}

vec3_cross :: proc(u, v: vec3) -> vec3 {
	x := u.y * v.z - u.z * v.y
	y := u.z * v.x - u.x * v.z
	z := u.x * v.y - u.y * v.x
	return {x, y, z}
}

vec3_unit :: proc(v: vec3) -> vec3 {
	return v / vec3_length(v)
}

Ray :: struct {
	orig: vec3,
	dir:  vec3,
}

ray_at :: proc(r: Ray, t: f64) -> vec3 {
	return r.orig + r.dir * t
}

ray_hit_sphere :: proc(center: vec3, radius: f64, r: Ray) -> f64 {
	oc := center - r.orig
	a := vec3_length_squared(r.dir)
	h := vec3_dot(r.dir, oc)
	c := vec3_length_squared(oc) - radius * radius
	discriminant := h * h - a * c

	if discriminant < 0 {
		return -1
	} else {
		return (h - math.sqrt(discriminant)) / a
	}
}

ray_color :: proc(r: Ray) -> vec3 {
	t := ray_hit_sphere(vec3{0, 0, -1}, 0.5, r)
	if (t > 0) {
		N := vec3_unit(ray_at(r, t) - vec3{0, 0, -1})
		return 0.5 * vec3{N.x + 1, N.y + 1, N.z + 1}
	}
	unit_direction := vec3_unit(r.dir)
	a := 0.5 * (unit_direction.y + 1.0)
	return (1.0 - a) * vec3{1.0, 1.0, 1.0} + a * vec3{0.5, 0.7, 1.0}
}


Image :: struct {
	width:  int,
	height: int,
	pixels: [][3]f64,
}

image_create :: proc(width, height: int) -> Image {
	return {width, height, make([][3]f64, width * height)}
}

image_save :: proc(image: ^Image) {
	fmt.printf("P3\n%d %d\n255\n", image.width, image.height, flush = false)
	for pixel in image.pixels {
		fmt.printf(
			"%d %d %d\n",
			byte(pixel.r * 255.999),
			byte(pixel.g * 255.999),
			byte(pixel.b * 255.999),
			flush = false,
		)
	}
	fmt.printf("")
}

main :: proc() {
	// Calculate image size
	image_width := 640
	image_height := int(f64(image_width) / (16.0 / 9.0))
	if image_height < 1 {image_height = 1}

	// Camera
	focal_length := 1.0
	viewport_height := 2.0
	viewport_width := viewport_height * (f64(image_width) / f64(image_height))
	camera_center := vec3{0, 0, 0}

	// Calculate the vectors across the horizontal and down the vertical viewport edges.
	viewport_u := vec3{viewport_width, 0, 0}
	viewport_v := vec3{0, -viewport_height, 0}

	// Calculate the horizontal and vertical delta vectors from pixel to pixel.
	pixel_delta_u := viewport_u / f64(image_width)
	pixel_delta_v := viewport_v / f64(image_height)

	// Calculate the location of the upper left pixel.
	viewport_upper_left :=
		camera_center - vec3{0, 0, focal_length} - viewport_u / 2 - viewport_v / 2
	pixel00_loc := viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v)

	// Create image
	image := image_create(image_width, image_height)
	for j := 0; j < image.height; j += 1 {
		for i := 0; i < image.width; i += 1 {
			pixel := &image.pixels[j * image.width + i]
			pixel_center := pixel00_loc + (f64(i) * pixel_delta_u) + (f64(j) * pixel_delta_v)
			ray_direction := pixel_center - camera_center
			r := Ray{camera_center, ray_direction}
			pixel^ = ray_color(r)
		}
	}
	image_save(&image)
}
