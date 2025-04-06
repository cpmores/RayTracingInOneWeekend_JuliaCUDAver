include("../kernel/render_kernel.jl")

function file_write(pixels, width, height)
    open(joinpath(@__DIR__, "../../output/test1.ppm"), "w") do file
        println(file, "P3\n$width $height\n255")
        for j in 1:height, i in 1:width
            rgb = color2rgb(pixels[j, i])
            println(file, rgb.x, " ", rgb.y, " ", rgb.z)
        end
    end
end


function gpu_render(width=400)
    # world set
    world_cpu = create_world_mut()
    color1 = Color(1.0f0, 1.0f0, 1.0f0)
    color2 = Color(0.2f0, 0.3f0, 0.7f0)
    color3 = Color(0.8f0, 0.8f0, 0.8f0)
    color4 = Color(0.8f0, 0.6f0, 0.2f0)
    # sphere1 = Sphere(Point3(0.0f0, 0.0f0, -1.2f0), 0.5f0, Lambertian, color1 )
    # sphere3 = Sphere(Point3(-1.0f0, 0.0f0, -1.0f0), 0.5f0, Dielectric, color3 )
    # sphere4 = Sphere(Point3(1.0f0, 0.0f0, -1.0f0), 0.5f0, Metal, color4 )
    # world_add(world_cpu, sphere1)
    # world_add(world_cpu, sphere2)
    # world_add(world_cpu, sphere3)
    # world_add(world_cpu, sphere4)

    ball1 = Sphere(Point3(0.0f0, 1.0f0, 0.0f0), 1.0f0, Lambertian, Color(0.1, 0.2, 0.5))
    ball2 = Sphere(Point3(-4.0f0, 1.0f0, 0.0f0), 1.0f0, Dielectric, color1)
    ball3 = Sphere(Point3(4.0f0, 1.0f0, 0.0f0), 1.0f0, Metal, Color(1.0f0, 1.0f0, 1.0f0))
    ground = Sphere(Point3(0.0f0, -1000f0, 0.0f0), 1000.0f0, Lambertian, color2)

    world_add(world_cpu, ground)
    world_add(world_cpu, ball1)
    world_add(world_cpu, ball2)
    world_add(world_cpu, ball3)

    materials = [:Metal, :Lambertian, :Dielectric]

    for a in -11:11
        for b in -11:11
            mater = materials[rand(1:length(materials))]
            rand_color = Color(random_01(), random_01(), random_01())
            radius = 0.2
            center = Point3(a + 0.9 * random_01(), radius, b + 0.9 * random_01())
            
            if norm(center - Point3(4, 0.2, 0)) > 0.9
                if mater == :Metal
                    mat = Metal
                elseif mater == :Lambertian
                    mat = Lambertian
                else
                    mat = Dielectric
                end
                world_add(world_cpu, Sphere(center, radius, mat, rand_color))
            end
        end
    end

    centers = [obj.center for obj in world_cpu.objects]
    radius = [obj.radius for obj in world_cpu.objects]
    mat = [obj.mat for obj in world_cpu.objects]
    albe = [obj.albedo for obj in world_cpu.objects]
    d_centers = CuArray(centers) 
    d_radius = CuArray(radius)
    d_material = CuArray(mat)
    d_albedo = CuArray(albe)
    object_count = Int32(length(centers))


    aspect_ratio = 16.0f0 / 9.0f0
    width = Int32(width)
    sample_per_pixel = Int32(500)
    reflect_times::Int32 = 50
    vfov = 20.0f0
    lookfrom = Point3(13.0f0, 2.0f0, 3.0f0)
    lookat = Point3(0.0f0, 0.0f0, 0.0f0)
    vup = Vec3(0.0f0, 1.0f0, 0.0f0)

    cam = init_camera(
        aspect_ratio, width, 
    sample_per_pixel, reflect_times, 
    vfov, lookfrom, lookat, vup
    )

    println("cam.vfov: ", cam.vfov)
    println("cam.sample_per_pixel: ", cam.sample_per_pixel)
    println("cam.image_height: ", cam.image_height)
    println("cam.image_width: ", cam.image_width)

    pixels_d = CUDA.zeros(Color, cam.image_height, cam.image_width)
    threads = (16, 16)
    blocks = (ceil(Int, cam.image_width / threads[1]), ceil(Int, cam.image_height / threads[2]))
    CUDA.@sync @cuda threads=threads blocks=blocks render_kernel(
        d_albedo, d_material, d_centers, d_radius, object_count, pixels_d, cam
    )

    pixels = Array(pixels_d)

    file_write(pixels, cam.image_width, cam.image_height)
end

