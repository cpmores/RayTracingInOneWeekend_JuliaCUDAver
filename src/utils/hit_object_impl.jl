@inline function Init_rec() 
    hit_record(
        Point3(0.0f0, 0.0f0, 0.0f0),
        Vec3(0.0f0, 0.0f0, 0.0f0),
        0.0f0,
        true,
        Metal,
        Color(0.0f0, 0.0f0, 0.0f0)
    )
end
@inline function set_front_face(rec::hit_record, r::Rayer, outward_normal::Vec3, t::Float32, p::Point3, mat::Material, albedo::Color)
    front_face = dot(r.direction, outward_normal) < 0
    normal = front_face ? outward_normal : -outward_normal
    return hit_record(p, normal, t, front_face, mat, albedo)
end

@inline function hit(sphere::Sphere, r::Rayer, inter::Interval, rec::hit_record)
    oc = sphere.center - r.origin
    a = dot(r.direction, r.direction)
    h = dot(r.direction, oc)
    c = dot(oc, oc) - sphere.radius * sphere.radius
    discriminant = h * h -  a *c

    if (discriminant < 0) 
        return false, rec
    end
    sqrtd = sqrt(discriminant)

    t = (h - sqrtd) / a
    if (!inter_contains(inter, t)) 
        t = (h + sqrtd) / a 
        if (!inter_contains(inter, t)) 
            return false, rec
        end
    end

    p = ray_at(r, t)
    outward_normal = (p - sphere.center) / sphere.radius
    new_rec = set_front_face(rec, r, outward_normal, t, p, sphere.mat, sphere.albedo)

    return true, new_rec

end



@inline function hit(albedo, material, centers,radius,object_count, r::Rayer, inter::Interval, rec::hit_record)
    hit_anything = false
    closest_so_far = inter.max
    
    for i in 1:object_count
        center = centers[i]
        radiuss = radius[i]
        mat = material[i]
        albe = albedo[i]
        
        temp_rec = hit_record(Vec3(0,0,0), Vec3(0,0,0), 0.0f0, false, Metal, Color(0.0f0, 0.0f0, 0.0f0))
        hit_result, new_rec = hit(Sphere(center, radiuss, mat, albe), r, Interval(inter.min, closest_so_far), temp_rec)
        
        if hit_result
            hit_anything = true
            closest_so_far = new_rec.t
            rec = new_rec
        end
    end
    
    return hit_anything, rec
end

# mutable world functions
function world_add(world::hittable_list_cpu, obj::hittable)
    push!(world.objects, obj)
end

function world_clear(world::hittable_list_cpu)
    empty!(world.objects)
end

function create_world_mut()
    hittable_list_cpu(Vector{hittable}())
end

