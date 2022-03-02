module CPUSummary

using Static
using Static: Zero, One, gt, lt
using IfElse: ifelse
export cache_size, cache_linesize, cache_associativity, cache_type,
  cache_inclusive, num_cache, num_cores, num_threads

include("generic_topology.jl")

end
