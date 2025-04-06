include("../src/utils/classes_decl.jl")
include("../src/utils/classes_impl.jl")
u = Vec3(1.0, 2.0, 3.0)
v = Vec3(3.0, 2.0, 1.0)
s = Float32(100.0)

println("u dot v: ",dot(u, v))
println("u + v: ",u + v)
println("u * s: ",u * s)
println("norm(u): ", norm(u))
println("normalize(u): ", normalize(u))
println("cross: ", cross(u, v))

v1 = Vec3(1.0, 2.0, 3.0)
v2 = Vec3(4.0, 5.0, 6.0)

println(v1 + v2)          # Vec3{Float64}(5.0, 7.0, 9.0)
println(v1 - v2)          # Vec3{Float64}(-3.0, -3.0, -3.0)
println(-v1)              # Vec3{Float64}(-1.0, -2.0, -3.0)
println(v1 * Float32(2))           # Vec3{Float64}(2.0, 4.0, 6.0)
println(Float32(2.0) * v1)           # Vec3{Float64}(2.0, 4.0, 6.0)
println(v1 / Float32(2))           # Vec3{Float64}(0.5, 1.0, 1.5)
println(dot(v1, v2))      # 32.0
println(sum(v1))          # 6.0
println(norm(v1))         # 3.7416573867739413
println(normalize(v1))    # Vec3{Float64}(0.267..., 0.534..., 0.801...)
println(cross(v1, v2))    # Vec3{Float64}(-3.0, 6.0, -3.0)
