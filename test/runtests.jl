using CPUSummary
using Test

@testset "CPUSummary.jl" begin

  @test @inferred(CPUSummary.sys_threads()) == Sys.CPU_THREADS::Int
  @test @inferred(CPUSummary.num_threads()) == Threads.nthreads()
  
  println("vector_width.jl")
  @time @testset "vector_width.jl" begin
    for T ∈ (Float32,Float64)
      @test @inferred(CPUSummary.pick_vector_width(T)) * @inferred(CPUSummary.static_sizeof(T)) === @inferred(CPUSummary.register_size(T)) === @inferred(CPUSummary.register_size())
    end
    for T ∈ (Int8,Int16,Int32,Int64,UInt8,UInt16,UInt32,UInt64)
      @test @inferred(CPUSummary.pick_vector_width(T)) * @inferred(CPUSummary.static_sizeof(T)) === @inferred(CPUSummary.register_size(T)) === @inferred(CPUSummary.simd_integer_register_size())
    end
    @test CPUSummary.static_sizeof(BigFloat) === CPUSummary.static_sizeof(Int)
    @test CPUSummary.static_sizeof(Float32) === CPUSummary.static_sizeof(Int32) === CPUSummary.StaticInt(4)

    @test @inferred(CPUSummary.pick_vector_width(Float64, Int32, Float64, Float32, Float64)) * CPUSummary.static_sizeof(Float64) === @inferred(CPUSummary.register_size())
    @test @inferred(CPUSummary.pick_vector_width(Float64, Int32)) * CPUSummary.static_sizeof(Float64) === @inferred(CPUSummary.register_size())

    @test @inferred(CPUSummary.pick_vector_width(Float32, Float32)) * CPUSummary.static_sizeof(Float32) === @inferred(CPUSummary.register_size())
    @test @inferred(CPUSummary.pick_vector_width(Float32, Int32)) * CPUSummary.static_sizeof(Float32) === @inferred(CPUSummary.simd_integer_register_size())

    @test all(i ->  CPUSummary.intlog2(1 << i) == i, 0:(Int == Int64 ? 53 : 30))
    FTypes = (Float32, Float64)
    Wv = ntuple(i -> @inferred(CPUSummary.register_size()) >> (i+1), Val(2))
    for (T, N) in zip(FTypes, Wv)
      W = @inferred(CPUSummary.pick_vector_width(T))
      # @test Vec{Int(W),T} == CPUSummary.pick_vector(W, T) == CPUSummary.pick_vector(T)
      @test W == @inferred(CPUSummary.pick_vector_width(W, T))
      @test W === @inferred(CPUSummary.pick_vector_width(W, T)) == @inferred(CPUSummary.pick_vector_width(T))
      while true
        W >>= CPUSummary.One()
        W == 0 && break
        W2, Wshift2 = @inferred(CPUSummary.pick_vector_width_shift(W, T))
        @test W2 == CPUSummary.One() << Wshift2 == @inferred(CPUSummary.pick_vector_width(W, T)) == CPUSummary.pick_vector_width(Val(Int(W)),T)  == W
        @test CPUSummary.StaticInt(W) === CPUSummary.pick_vector_width(Val(Int(W)), T) === CPUSummary.pick_vector_width(W, T)
        for n in W+1:2W
          W3, Wshift3 = CPUSummary.pick_vector_width_shift(CPUSummary.StaticInt(n), T)
          @test W2 << 1 == W3 == 1 << (Wshift2+1) == 1 << Wshift3 == CPUSummary.pick_vector_width(CPUSummary.StaticInt(n), T) == CPUSummary.pick_vector_width(Val(n),T) == W << 1
          # @test CPUSummary.pick_vector(W, T) == CPUSummary.pick_vector(W, T) == Vec{Int(W),T}
        end
      end
    end

    # @test CPUSummary.nextpow2(0) == 1
    @test all(i -> CPUSummary.nextpow2(i) == i, 0:2)
    for j in 1:10
      l, u = (1<<j)+1, 1<<(j+1)
      @test all(i -> CPUSummary.nextpow2(i) == u, l:u)
    end

  end

end
