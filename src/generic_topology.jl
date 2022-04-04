
num_machines() = static(1)
num_sockets() = static(1)

function _get_num_threads()
  static((Sys.CPU_THREADS)::Int >> (Sys.ARCH !== :aarch64))
end

let nc = _get_num_threads()
  global num_l1cache() = nc
  global num_cores() = nc
end
let syst = static((Sys.CPU_THREADS)::Int)
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

if Sys.CPU_NAME === "tigerlake" ||
   Sys.CPU_NAME === "icelake" ||
   Sys.CPU_NAME === "icelake-server" ||
   Sys.CPU_NAME === "alderlake"
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{49152}()
elseif Sys.ARCH === :aarch64 && Sys.isapple()
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{131072}()
else
  cache_size(::Union{Val{1},StaticInt{1}}) = StaticInt{32768}()
end
cache_associativity(::Union{Val{1},StaticInt{1}}) = StaticInt{0}()
cache_type(::Union{Val{1},StaticInt{1}}) = Val{:Data}()
cache_inclusive(::Union{Val{1},StaticInt{1}}) = False()

if Sys.CPU_NAME === "skylake-avx512" || Sys.CPU_NAME === "cascadelake"
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{1048576}()
elseif Sys.CPU_NAME === "tigerlake" ||
       Sys.CPU_NAME === "icelake-server" ||
       Sys.CPU_NAME === "alderlake"
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{1310720}()
elseif occursin("zn", Sys.CPU_NAME) || occursin("icelake", Sys.CPU_NAME)
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{524288}()
elseif Sys.ARCH === :aarch64 && Sys.isapple()
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{12582912}()
else
  cache_size(::Union{Val{2},StaticInt{2}}) = StaticInt{262144}()
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
cache_size(::Union{Val{3},StaticInt{3}}) = num_cores() * StaticInt{1441792}()

function __init__()
  ccall(:jl_generating_output, Cint, ()) == 1 && return
  nc = _get_num_threads()
  syst = Sys.CPU_THREADS::Int
  nt = Threads.nthreads()
  if nc != num_l1cache()
    @eval num_l1cache() = static($nc)
  end
  if nc != num_cores()
    @eval num_cores() = static($nc)
  end
  if syst != sys_threads()
    @eval sys_threads() = static($syst)
  end
  if nt != num_threads()
    @eval num_threads() = static($nt)
  end
end
