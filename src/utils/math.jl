using Random
@inline function deg2rad(degrees::Float32)::Float32
    degrees * π / 180.0f0
end

@inline function random_01()
    Float32(rand())
end

@inline function random_inter(min::Float32, max::Float32)
    min + (max - min) * random_01()
end

@inline function random_vec()
    return Vec3(random_01(), random_01(),random_01())
end

@inline function random_vec_inter(min::Float32, max::Float32)
    return Vec3(random_inter(min, max), random_inter(min, max),random_inter(min, max))
end

@inline function random_unit_vec()
    while true 
        v = random_vec_inter(-1.0f0, 1.0f0)
        if norm(v) <= 1 && norm(v) > 1e-160
            return normalize(v)
        end
    end
end

@inline function random_on_surface(normal::Vec3)
    v = random_unit_vec()
    if (dot(v, normal) > 1e-160)
        return v
    else
        return -v
    end
end

# println(random_01())
# println(random_inter(0.2f0, 5.5f0))