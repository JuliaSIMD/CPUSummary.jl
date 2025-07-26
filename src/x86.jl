using CpuId

num_machines() = static(1)
num_sockets() = static(1)

_get_num_cores()::Int = clamp(CpuId.cpucores(), 1, (get_cpu_threads())::Int)

let nc = static(_get_num_cores())
  global num_l1cache() = nc
  global num_cores() = nc
end
let syst = static((get_cpu_threads())::Int)
  global sys_threads() = syst
end
num_l2cache() = num_l1cache()
num_l3cache() = static(1)
num_l4cache() = static(0)

const PrecompiledCacheSize = let cs = CpuId.cachesize()
  ntuple(i -> i == 3 ? cs[3] ÷ _get_num_cores() : cs[i], length(cs))
end
const PrecompiledCacheInclusive = CpuId.cacheinclusive()
# cache_inclusive(_) = False()
# @noinline function _eval_cache_size(cachesize)
#   for (i, csi) in enumerate(cachesize)
#     @eval cache_size(::Union{Val{$i},StaticInt{$i}}) = $(static(csi))
#   end
# end
# @noinline function _eval_cache_inclusive(cacheinclusive)
#   for (i, cii) in enumerate(cacheinclusive)
#     @eval cache_inclusive(::Union{Val{$i},StaticInt{$i}}) = $(static(cii != 0))
#   end
# end
# _eval_cache_size(PrecompiledCacheSize)
# _eval_cache_inclusive(PrecompiledCacheInclusive)


cache_size(::Val{S}) where {S} = cache_size(S)
cache_size(::StaticInt{S}) where {S} = cache_size(S)

@inline @generated function cache_size(cachesize)
  cs = let cs = CpuId.cachesize()
    ntuple(i -> i == 3 ? cs[3] ÷ _get_num_cores() : cs[i], length(cs))
  end

  cache_sizes = map(enumerate(cs)) do (i, csi)

    return :(
      if cachesize == $i
        return static($csi)
      end
    )
  end

  return quote
    begin
      $(cache_sizes...)
    end
  end

end
cache_inclusive(::Val{S}) where {S} = cache_inclusive(S)
cache_inclusive(::StaticInt{S}) where {S} = cache_inclusive(S)

@inline @generated function cache_inclusive(cacheinclusive)
  ci = CpuId.cacheinclusive()

  cache_inclusives = map(enumerate(ci)) do (i, cii)
    val = cii != 0
    return :(
      if cacheinclusive == $i
        return static($val)
      end
    )
  end

  if !isempty(cache_inclusives)
    push!(cache_inclusives, :(return False()))
  else
    cache_inclusives = [:(return False())]
  end

  return quote
    begin
      $(cache_inclusives...)
    end
  end


end


# TODO: implement
cache_associativity(_) = static(0)

cache_type(::Union{Val{1},StaticInt{1}}) = Val{:Data}()
cache_type(_) = Val{:Unified}()
# cache_type(::Union{Val{2},StaticInt{2}}) = Val{:Unified}()
# cache_type(::Union{Val{3},StaticInt{3}}) = Val{:Unified}()
let lnsize = static(CpuId.cachelinesize())
  global cache_linesize(_) = lnsize
end
# cache_size(_) = StaticInt{0}()

# cache_size(::Union{Val{3},StaticInt{3}}) = num_cores() * StaticInt{1441792}()
function _extra_init()
  cs = let cs = CpuId.cachesize()
    ntuple(i -> i == 3 ? cs[3] ÷ _get_num_cores() : cs[i], length(cs))
  end
  cs !== PrecompiledCacheSize && _eval_cache_size(cs)
  ci = CpuId.cacheinclusive()
  ci !== PrecompiledCacheInclusive && _eval_cache_inclusive(ci)
  return nothing
end
