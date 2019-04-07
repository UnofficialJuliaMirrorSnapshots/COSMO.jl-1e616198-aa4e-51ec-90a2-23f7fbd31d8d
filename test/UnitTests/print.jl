using COSMO, Test, Random

settings = COSMO.Settings()
iter = 10
cost = 20.
r_prim = 1.5e-3
r_dual = 1.2e-2
status = :Solved
rt = 0.7


@testset "Printing" begin
   @test COSMO.print_iteration(settings, iter, cost, r_prim, r_dual) == nothing
   @test COSMO.print_iteration(settings, settings.check_termination, cost, r_prim, r_dual) == nothing
   @test COSMO.print_result(status, iter, cost, rt) == nothing
end
nothing
