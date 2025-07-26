
num_machines() = static(1)
num_sockets() = static(1)

_get_num_cores() = (get_cpu_threads())::Int >> (Sys.ARCH !== :aarch64)

let syst = static(get_cpu_threads()), nc = static(syst >> (Sys.ARCH !== :aarch64))
  global num_l1cache() = nc
  global num_cores() = nc
  global sys_threads() = syst
end
@static if Sys.ARCH === :aarch64
  num_l2cache() = static(1)
  num_l3cache() = static(0)
else
  num_l2cache() = num_l1cache()
  num_l3cache() = static(1)
end
num_l4cache() = static(0)

if Sys.ARCH === :aarch64 && (Sys.isapple() || occursin("apple", Sys.CPU_NAME::String))
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{131072}()
else
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{32768}()
end
cache_associativity(::Union{Val{1},StaticInt{1}}) = StaticInt{0}()
cache_type(::Union{Val{1},StaticInt{1}}) = Val{:Data}()
cache_inclusive(::Union{Val{1},StaticInt{1}}) = False()

if Sys.ARCH === :aarch64 && (Sys.isapple() || occursin("apple", Sys.CPU_NAME::String))
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{3145728}()
else
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{65536}()
end
cache_associativity(::Union{Val{2},StaticInt{2}}) = StaticInt{0}()
cache_type(::Union{Val{2},StaticInt{2}}) = Val{:Unified}()
cache_inclusive(_) = False()
@static if Sys.ARCH === :aarch64 &&
           (Sys.isapple() || occursin("apple", Sys.CPU_NAME::String))
  cache_linesize(_) = StaticInt{128}() # assume...
else
  cache_linesize(_) = StaticInt{64}() # assume...
end
cache_size(_) = StaticInt{0}()

@static if Sys.ARCH === :aarch64 &&
           (Sys.isapple() || occursin("apple", Sys.CPU_NAME::String))
else
  cache_type(::Union{Val{3},StaticInt{3}}) = Val{:Unified}()
  cache_size(::Union{Val{3},StaticInt{3}}) = StaticInt{1441792}()
end

_extra_init() = nothing
