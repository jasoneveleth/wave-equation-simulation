using Plots
using Lazy
gr()
using Random

function run_simulation(dim::Int)
    # alpha is the "speed" of the wave (proportional to the c in the wave equation)
    alpha = 0.34

    x = y = range(-1, 1, length = dim)
    w = zeros(3, dim, dim)

    function put_drop!(x, y)
        r = 2
        w[1, x-r:x+r, y-r:y+r] = 1.5 * -gaussian_kernel(2*r + 1, 1.0)
    end

    for i in Lazy.range()
        function play_noise!(x, y, amp=1)
            w[1, dim ÷ 2, dim ÷ 2] = amp * sin(i/2)
        end

        # wave equation update
        w[3, :, :] = w[2, :, :]
        w[2, :, :] = w[1, :, :]
        w[1, 2:end-1, 2:end-1] = (2 * w[2, 2:end-1, 2:end-1] - w[3, 2:end-1, 2:end-1] + 
            alpha * (w[2, 1:end-2, 2:end-1] + 
                    w[2, 2:end-1, 1:end-2] - 
                4*w[2, 2:end-1, 2:end-1] + 
                    w[2, 3:end, 2:end-1] + 
                    w[2, 2:end-1, 3:end]))

        # add a drop of water
        if rand() < 1/40
            put_drop!(rand(5:dim-5), rand(5:dim-5))
        end

        # play_noise!(dim ÷ 2, dim ÷ 2)

        z = clamp.(w[1,:,:], -1, 1)
        p = surface(x, y, z, clims=(-2,2), zlims=(-0.8, 0.8), camera=(30, 70), show=true)
        sleep(0.016) # to slow down the animation
    end
end

function gaussian_kernel(size::Int, σ::Float64)
    kernel = [exp(-0.5 * ((i - size÷2)^2 + (j - size÷2)^2) / σ^2) for i in 1:size, j in 1:size]
    return kernel / sum(kernel)  # Normalize the kernel
end

function run(dim::Int)
    try
        run_simulation(dim)
    catch e
        if !isa(e, InterruptException)
            rethrow(e)
        end
    end
end
