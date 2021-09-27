module CPUSummary

using Static, Hwloc
using Static: Zero, One, gt, lt
using IfElse: ifelse

export cache_size, cache_linesize, cache_associativity, cache_type,
  cache_inclusive, num_cache, num_cores, num_threads

include("topology.jl")
const BASELINE_CORES = Int(num_cores()) * ((Sys.ARCH === :aarch64) && Sys.isapple() ? 2 : 1)
function __init__()
  Sys.isapple() && Sys.ARCH === :aarch64 && return # detect M1
  ccall(:jl_generating_output, Cint, ()) == 1 && return
  safe_topology_load!()
  if count_attr(:Core) ≢ BASELINE_CORES
    redefine_attr_count()
    foreach(redefine_cache, 1:4)
  end
  redefine_num_threads()
  return nothing
end


end
