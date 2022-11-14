
num_machines() = static(1)
num_sockets() = static(1)

function _get_num_threads()::Int
  (get_cpu_threads())::Int >> (Sys.ARCH !== :aarch64)
end

const _get_num_cores = _get_num_threads  

let nc = static(_get_num_threads())
  global num_l1cache() = nc
  global num_cores() = nc
end
let syst = static((get_cpu_threads())::Int)
  global sys_threads() = syst
  global num_threads() = syst
end
@static if Sys.ARCH === :aarch64
  num_l2cache() = static(1)
  num_l3cache() = static(0)
else
  num_l2cache() = num_l1cache()
  num_l3cache() = static(1)
end
num_l4cache() = static(0)

if Sys.ARCH === :aarch64 && Sys.isapple()
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{131072}()
else
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{32768}()
end
cache_associativity(::Union{Val{1},StaticInt{1}}) = StaticInt{0}()
cache_type(::Union{Val{1},StaticInt{1}}) = Val{:Data}()
cache_inclusive(::Union{Val{1},StaticInt{1}}) = False()

if Sys.ARCH === :aarch64 && Sys.isapple()
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{3145728}()
else
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{65536}()
end
cache_associativity(::Union{Val{2},StaticInt{2}}) = StaticInt{0}()
cache_type(::Union{Val{2},StaticInt{2}}) = Val{:Unified}()
cache_inclusive(_) = False()
@static if Sys.isapple() && Sys.ARCH === :aarch64
  cache_linesize(_) = StaticInt{128}() # assume...
else
  cache_linesize(_) = StaticInt{64}() # assume...
end
cache_size(_) = StaticInt{0}()

cache_type(::Union{Val{3},StaticInt{3}}) = Val{:Unified}()
cache_size(::Union{Val{3},StaticInt{3}}) = StaticInt{1441792}()

_extra_init() = nothing
