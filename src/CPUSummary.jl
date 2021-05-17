module CPUSummary

using Static, Hwloc
using Static: Zero, One, gt, lt
using IfElse: ifelse

export has_feature, fma_fast, pick_vector_width, pick_vector_width_shift, register_count,
  cache_size, cache_linesize, cache_associativity, cache_type, cache_inclusive,
  num_cache, num_cores, num_threads, register_size, simd_integer_register_size


include("topology.jl")
include("cpu_info.jl")
if (Sys.ARCH === :x86_64) || (Sys.ARCH === :i686)
    include("cpu_info_x86.jl")
elseif Sys.ARCH === :aarch64
    include("cpu_info_aarch64.jl")
else
    include("cpu_info_generic.jl")
end
include("pick_vector_width.jl")

unwrap(::Val{S}) where {S} = S

@noinline function redefine()
  @debug "Defining CPU name."
  define_cpu_name()

  reset_features!()
  reset_extra_features!()
end
function __init__()
  ccall(:jl_generating_output, Cint, ()) == 1 && return
  safe_topology_load!()
  unwrap(cpu_name()) === Symbol(Sys.CPU_NAME::String) || redefine()
  if Hwloc.num_physical_cores() ≠ Int(num_cores()) * ((Sys.ARCH === :aarch64) && Sys.isapple() ? 2 : 1)
    redefine_attr_count()
    foreach(redefine_cache, 1:4)
  end
  redefine_num_threads()
  return nothing
end


end
