using PrecompileTools: @compile_workload

@compile_workload begin
  __init__()
  # `_extra_init()` is called by `__init__()`
  # However, it does not seem to be recognized correctly since we can
  # further reduce the time of `using CPUSummary` significantly by
  # precompiling it here in addition ot `__init__()`.
end
