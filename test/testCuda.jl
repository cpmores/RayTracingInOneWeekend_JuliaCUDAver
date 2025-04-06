using CUDA

# Define Vec3 (must be isbits)
struct Vec3
    x::Float32
    y::Float32
    z::Float32
end
@assert isbits(Vec3)  # Verify Vec3 is a bitstype

# Host-side struct (not passed to kernel directly)
struct HittableListGPU
    centers::CuVector{Vec3}  # Device array of Vec3
    radii::CuVector{Float32} # Device array of Float32
    count::Int32             # Scalar
end

# Prepare data and transfer to GPU
function pack_to_gpu(centers::Vector{Vec3}, radii::Vector{Float32}, count::Int32)
    @assert length(centers) == length(radii) == count
    d_centers = CuArray(centers)
    d_radii = CuArray(radii)
    return HittableListGPU(d_centers, d_radii, count)
end

# GPU kernel: Pass individual fields instead of the struct
function gpu_kernel(d_centers::CuDeviceVector{Vec3, 1}, d_radii::CuDeviceVector{Float32, 1}, count::Int32, output::CuDeviceVector{Float32, 1})
    idx = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if idx <= count
        center = d_centers[idx]  # Access Vec3
        radius = d_radii[idx]    # Access radius
        # Example computation
        output[idx] = center.x * radius + center.y + center.z
    end
    return
end

# Main function to run on GPU
function run_packed_on_gpu()
    # Sample data
    centers = [Vec3(1.0f0, 2.0f0, 3.0f0), Vec3(4.0f0, 5.0f0, 6.0f0)]
    radii = Float32[1.0, 2.0]
    count = Int32(2)

    # Pack and transfer to GPU
    hlist = pack_to_gpu(centers, radii, count)

    # Allocate output array on GPU
    d_output = CUDA.zeros(Float32, count)

    # Launch kernel with individual fields
    threads = min(256, count)
    blocks = cld(count, threads)
    @cuda threads=threads blocks=blocks gpu_kernel(hlist.centers, hlist.radii, hlist.count, d_output)

    # Synchronize and fetch results
    CUDA.synchronize()
    output = Array(d_output)
    return output
end

# Test
result = run_packed_on_gpu()
println("Result: ", result)