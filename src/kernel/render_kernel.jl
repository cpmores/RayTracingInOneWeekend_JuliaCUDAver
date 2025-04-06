include("../core/ray_color.jl")

function color2rgb(color::Color) 
    inter = Interval(0.0f0, 0.999f0)
    r = ceil(Int32, inter_clamp(inter, color.x) * 255.999)
    g = ceil(Int32, inter_clamp(inter, color.y) * 255.999)
    b = ceil(Int32, inter_clamp(inter, color.z) * 255.999)
    rgb = RGB(r, g, b)
    return rgb
end

@inline function get_ray(i, j,pixel00_loc, pixel_delta_u, pixel_delta_v, camera_center) 
    offset = random_sample()
    pixel_center = pixel00_loc + (Float32(i) + offset.x) * pixel_delta_u + (Float32(j)+ offset.y) * pixel_delta_v
    direction = pixel_center - camera_center
    Rayer(
        camera_center,
        direction
    )
end

function render_kernel(albe::CuDeviceVector{Color},mats::CuDeviceVector{Material}, centers::CuDeviceVector{Point3}, radius::CuDeviceVector{Float32}, object_count::Int32,
    pixels::CuDeviceMatrix{Color}, cam::Camera)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    j = (blockIdx().y - 1) * blockDim().y + threadIdx().y
    if i <= cam.image_width && j <= cam.image_height
        pixels[j, i] = Color(0.0f0, 0.0f0, 0.0f0)
        for _ in 1:cam.sample_per_pixel
            r = get_ray(i, j, cam.pixel00_loc, cam.pixel_delta_u, cam.pixel_delta_v, cam.center)
            color = ray_color(albe, mats, centers, radius, object_count, r, cam.reflect_times)
            pixels[j, i] += (color)
        end

        pixels[j, i] /= cam.sample_per_pixel
    end
    return nothing
end
