import Base: +, -, *, /, sum, sqrt
include("./math.jl")

@inline function +(u::Vec3, v::Vec3)::Vec3
    Vec3(u.x + v.x, u.y + v.y, u.z + v.z)
end

@inline function -(u::Vec3, v::Vec3)::Vec3
    Vec3(u.x - v.x, u.y - v.y, u.z - v.z)
end

@inline function -(u::Vec3)::Vec3
    Vec3(-u.x, -u.y, -u.z)
end

@inline function *(u::Vec3, s::Float32)::Vec3
    Vec3(u.x * s, u.y * s, u.z * s)
end

@inline function *(s::Float32, u::Vec3)::Vec3
    u * s
end

@inline function /(u::Vec3, s::Int32)::Vec3
    Vec3(u.x / Float32(s), u.y / Float32(s), u.z / Float32(s))
end

@inline function /(u::Vec3, s::Float32)::Vec3
    Vec3(u.x / s, u.y / s, u.z / s)
end

@inline function /(u::Vec3, s::Float64)::Vec3
    Vec3(u.x / Float32(s), u.y / Float32(s), u.z / Float32(s))
end

@inline function /(u::Vec3, s::Int64)::Vec3
    Vec3(u.x / Float32(s), u.y / Float32(s), u.z / Float32(s))
end

@inline function *(u::Vec3, v::Vec3)::Vec3
    Vec3(u.x * v.x, u.y * v.y, u.z * v.z)
end

@inline function sum(u::Vec3)::Float32
    u.x + u.y + u.z
end

@inline function dot(u::Vec3, v::Vec3)::Float32
    sum(Vec3(u.x * v.x, u.y * v.y, u.z * v.z))
end

@inline function norm(u::Vec3)::Float32
    sqrt(dot(u, u))
end

@inline function normalize(u::Vec3)::Vec3
    n = norm(u)
    u / n
end

@inline function cross(u::Vec3, v::Vec3)::Vec3
    Vec3(u.y * v.z - u.z * v.y, u.z * v.x - u.x * v.z, u.x * v.y - u.y * v.x)
end

@inline function ray_at(r::Rayer, t::Float32)
    return r.origin + t * r.direction
end

@inline function sqrt(u::Vec3) 
    Vec3(sqrt(u.x), sqrt(u.y), sqrt(u.z))
end

# interval functions
@inline function inter_size(inter::Interval) 
    inter.max - inter.min
end

@inline function inter_contains(inter::Interval, x::Float32) 
    inter.min <= x && inter.max >= x
end

@inline function inter_surrounds(inter::Interval, x::Float32) 
    inter.min < x && inter.max > x
end


@inline function inter_clamp(inter::Interval, x::Float32)
    if (x < inter.min) return inter.min end
    if (x > inter.max) return inter.max end
    return x
end

function init_camera(
    aspect_ratio::Float32, image_width::Int32, 
    sample_per_pixel::Int32, reflect_times::Int32, 
    vfov::Float32, lookfrom::Point3, lookat::Point3,
    vup::Vec3
    )

    # set image height and width
    image_height = round(Int32, image_width / aspect_ratio)
    image_height = (image_height < 1) ? 1 : image_height

    # camera params
    focal_length = norm(lookfrom - lookat)
    theta = deg2rad(vfov)
    h = tan(theta/2.0f0)
    viewport_height = 2.0f0 * h * focal_length
    viewport_width  = viewport_height * (Float32(image_width) / image_height)
    camera_center = lookfrom

    w = normalize(lookfrom - lookat)
    u = normalize(cross(vup, w))
    v = cross(w, u)

    # viewport vector set
    viewport_u = viewport_width * u
    viewport_v = viewport_height * -v
    
    # viewport unit vector set
    pixel_delta_u = viewport_u / image_width
    pixel_delta_v = viewport_v / image_height

    # start point
    viewport_upper_left = camera_center - focal_length * w - viewport_u / 2 - viewport_v / 2
    pixel00_loc = viewport_upper_left + 0.5f0 * (pixel_delta_u + pixel_delta_v)

    return Camera(
        aspect_ratio,
        image_width,
        sample_per_pixel,
        reflect_times,
        vfov,
        lookfrom,
        lookat,
        vup,
        image_height,
        camera_center,
        pixel00_loc,
        pixel_delta_u,
        pixel_delta_v,
        u,v,w
    )
end

@inline function random_sample() 
    return Vec3(random_01() - 0.5f0, random_01() - 0.5f0, 0.0f0)
end