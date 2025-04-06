include("../utils/classes_decl.jl")
include("../utils/classes_impl.jl")
include("../utils/hit_object_impl.jl")
include("../utils/reflect_impl.jl")


function ray_color(albe::CuDeviceVector{Color}, mats::CuDeviceVector{Material}, centers::CuDeviceVector{Point3}, radius::CuDeviceVector{Float32}, object_count::Int32, r::Rayer, reflect_times::Int32)::Color
    rec = Init_rec()
    inter = Interval(0.001f0, Inf32)
    choose, new_rec = hit(albe, mats, centers, radius, object_count, r, inter, rec)
    
    times_count::Int32 = 0
    color = Color(0.0f0, 0.0f0, 0.0f0)
    ray = r
    while choose && times_count < reflect_times
        N = normalize(new_rec.normal)
        if times_count == 0
            color = new_rec.albedo * Color(1.0f0, 1.0f0, 1.0f0)
        else 
            color *= new_rec.albedo 
        end
        

        ray = surface_reflect(new_rec, ray.direction, new_rec.normal, new_rec.mat)
        choose, new_rec = hit(albe, mats, centers, radius, object_count, ray, inter, rec)
        times_count = times_count + 1
    end

    if times_count == reflect_times 
        return Color(0.0f0, 0.0f0, 0.0f0)
    end
    
    if times_count > 0 
        return color
    end

    unit_direction = normalize(r.direction)
    a = 0.5f0 * (unit_direction.y + 1.0f0)
    return (1.0f0 - a) * Color(1.0f0, 1.0f0, 1.0f0) + a * Color(0.5f0, 0.7f0, 1.0f0)
end