# const USE_HWLOC = parse(Bool, get(ENV, "CPUSUMMARY_HWLOC", "true"))
# if !USE_HWLOC
#   run(`$(Base.julia_cmd()) --project=$(Base.active_project()) -e'using CPUSummary; CPUSummary.use_hwloc(false)'`)
# end

using CPUSummary
using Test

@testset "CPUSummary.jl" begin
  @test @inferred(CPUSummary.sys_threads()) == Sys.CPU_THREADS::Int
  @test @inferred(CPUSummary.num_threads()) == Threads.nthreads()
  # if USE_HWLOC
  #   for i ∈ 1:4
  #     @test CPUSummary.redefine_cache(1) === nothing
  #   end
  # else
  #   @test !isdefined(CPUSummary, :redefine_cache)
  # end
end
