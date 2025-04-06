@inline function refract(uv::Vec3, n::Vec3 ,ri::Float32)
    cos_theta = dot(-uv, n) < 1.0f0 ? dot(-uv, n) : 1.0f0
    sin_theta = sqrt(1.0f0 - cos_theta * cos_theta)
    cannot_reflect = ri * sin_theta > 1.0f0
    r_out_perp = ri * (uv + cos_theta * n)
    inter = (1.0f0 - dot(r_out_perp, r_out_perp)) < 0 ? -(1.0f0 - dot(r_out_perp, r_out_perp)) : (1.0f0 - dot(r_out_perp, r_out_perp))
    r_out_parallel = -sqrt(inter) * n
    r_out_parallel + r_out_perp, cannot_reflect
end
@inline function surface_reflect(rec::hit_record, v::Vec3, normal::Vec3, mat::Material)
    if mat == Metal
        reflected = v - 2 * dot(v, normal) * normal
        return Rayer(rec.p, reflected)
    elseif mat == Lambertian
        scattered = random_unit_vec() + rec.normal
        return Rayer(rec.p, scattered)
    elseif mat == Dielectric
        ri = rec.front_face ? 1.0f0 / 1.5f0 : 1.5f0 # fixed
        n = normalize(v)
        refracted, cannot_reflect = refract(n, rec.normal, ri)
        if cannot_reflect
            refracted = v - 2 * dot(v, normal) * normal
        end
        return Rayer(
            rec.p,
            refracted
        )
    else
        error("Unsupported material type")
    end
end
