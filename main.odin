package main

import fmt "core:fmt"
import math "core:math"

vec3 :: [3]f32

vec3_length :: proc(v: vec3) -> f32 {
	squared := v * v
	return math.sqrt(squared.x + squared.y + squared.z)
}

vec3_dot :: proc(u, v: vec3) -> f32 {
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

ray_at :: proc(ray: Ray, t: f32) -> vec3 {
	return ray.orig + ray.dir * t
}

Image :: struct {
	width:  int,
	height: int,
	pixels: [][3]byte,
}

image_create :: proc(width, height: int) -> Image {
	return {width, height, make([][3]byte, width * height)}
}

image_gradient :: proc(image: ^Image) {
	for i := 0; i < image.height; i += 1 {
		for j := 0; j < image.width; j += 1 {
			pixel := &image.pixels[i * image.width + j]
			pixel.r = byte(f32(i) / f32(image.height) * 255.999)
			pixel.g = byte(f32(j) / f32(image.width) * 255.999)
		}
	}
}

image_save :: proc(image: ^Image) {
	fmt.printf("P3\n%d %d\n255\n", image.width, image.height, flush = false)
	for pixel in image.pixels {
		fmt.printf("%d %d %d\n", pixel.r, pixel.g, pixel.b, flush = false)
	}
	fmt.printf("")
}


main :: proc() {
	// Create image
	image := image_create(640, 480)
	image_gradient(&image)
	image_save(&image)
}
