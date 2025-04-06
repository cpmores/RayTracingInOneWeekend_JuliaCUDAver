module MyGeometry

using CUDA
using BenchmarkTools
using Images
using Adapt

export Vec3, Rayer, Point3, Color, RGB, hit_record, hittable, Sphere
export +, -, *, /, sum, dot, norm, normalize, cross, ray_at

include("utils/classes_decl.jl") 
include("utils/classes_impl.jl")

end