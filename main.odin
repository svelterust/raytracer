package main

import fmt "core:fmt"

Image :: struct {
	width:  int,
	height: int,
	pixels: [][3]byte,
}

create_image :: proc(width: int, height: int) -> Image {
	return {width, height, make([][3]byte, width * height)}
}

render_gradient :: proc(image: ^Image) {
	for i := 0; i < image.height; i += 1 {
		for j := 0; j < image.width; j += 1 {
			pixel := &image.pixels[i * image.width + j]
			pixel.r = byte(f32(i) / f32(image.height) * 255.999)
			pixel.g = byte(f32(j) / f32(image.width) * 255.999)
		}
	}
}

save_image :: proc(image: ^Image) {
	fmt.printf("P3\n%d %d\n255\n", image.width, image.height)
	for pixel in image.pixels {
		fmt.printf("%d %d %d\n", pixel.r, pixel.g, pixel.b)
	}
}

main :: proc() {
	// Create image
	image := create_image(640, 480)
	render_gradient(&image)
	save_image(&image)
}
