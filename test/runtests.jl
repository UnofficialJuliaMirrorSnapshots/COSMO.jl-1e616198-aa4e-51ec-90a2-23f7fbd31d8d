
using COSMO, Random, Test, Pkg
rng = Random.MersenneTwister(12345)

include("./UnitTests/COSMOTestUtils.jl")

@testset "All Unit Tests" begin

  include("./UnitTests/simple.jl")
  include("./UnitTests/sets.jl")
  include("./UnitTests/constraints.jl")
  include("./UnitTests/kktsolver.jl")
  include("./UnitTests/model.jl")
  include("./UnitTests/qp-lasso.jl")
  include("./UnitTests/qp-box.jl")
  include("./UnitTests/socp-lasso.jl")
  include("./UnitTests/closestcorr.jl")
  include("./UnitTests/print.jl")
  include("./UnitTests/InfeasibilityTests/runTests.jl")
  include("./UnitTests/algebra.jl")
  include("./UnitTests/splitvector.jl")
  include("./UnitTests/interface.jl")
  include("./UnitTests/chordal_decomposition_triangle.jl")
  include("./UnitTests/psd_completion.jl")
  include("./UnitTests/moi_wrapper.jl")

  # optional unittests
  if in("Pardiso",keys(Pkg.installed()))
    include("./UnitTests/options_factory.jl")
  end
end
nothing
