# src/utils/classes.jl
using CUDA
using BenchmarkTools
using Images
using Adapt

struct Vec3
    x::Float32
    y::Float32
    z::Float32
end

Base.zero(::Type{Vec3}) = Vec3(0.0f0, 0.0f0, 0.0f0)

struct RGB
    x::Int32
    y::Int32
    z::Int32
end

struct Rayer
    origin::Vec3
    direction::Vec3
end

const Point3 = Vec3
const Color = Vec3

@enum Material begin
    Metal
    Lambertian
    Dielectric
end
# record the hit point in the surface
struct hit_record 
    p::Point3 
    normal::Vec3
    t::Float32
    front_face::Bool
    mat::Material
    albedo::Color
end


# start hit sphere

abstract type hittable end

struct Sphere <: hittable
    center::Point3
    radius::Float32
    mat::Material
    albedo::Color
end

# mutable before going to GPU
mutable struct hittable_list_cpu <: hittable
    objects::Vector{hittable}
end

struct Interval
    min::Float32
    max::Float32
end

struct Camera
    aspect_ratio::Float32
    image_width::Int32
    sample_per_pixel::Int32
    reflect_times::Int32
    vfov::Float32
    lookfrom::Point3
    lookat::Point3
    vup::Vec3

    image_height::Int32
    center::Point3
    pixel00_loc::Point3
    pixel_delta_u::Vec3
    pixel_delta_v::Vec3
    u::Vec3
    v::Vec3
    w::Vec3
end

Adapt.adapt_structure(to, v::Vec3) = Vec3(Adapt.adapt(to, v.x), Adapt.adapt(to, v.y), Adapt.adapt(to, v.z))
Adapt.adapt_structure(to, r::Rayer) = Rayer(Adapt.adapt(to, r.origin), Adapt.adapt(to, r.direction))
Adapt.adapt_structure(to, s::hit_record) = hit_record(Adapt.adapt(to, s.p), Adapt.adapt(to, s.normal), Adapt.adapt(to, s.t), Adapt.adapt(to, s.front_face), Adapt.adapt(to, s.mat), Adapt.adapt(to, s.albedo))
Adapt.adapt_structure(to, s::Sphere) = Sphere(Adapt.adapt(to, s.center), Adapt.adapt(to, s.radius), Adapt.adapt(to, s.mat), Adapt.adapt(to, s.albedo))
Adapt.adapt_structure(to, s::Interval) = Interval(Adapt.adapt(to, s.min), Adapt.adapt(to, s.max))


