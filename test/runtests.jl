using CPUSummary
using Test

@testset "CPUSummary.jl" begin

  @test @inferred(CPUSummary.sys_threads()) == Sys.CPU_THREADS::Int
  @test @inferred(CPUSummary.num_threads()) == Threads.nthreads()
end
