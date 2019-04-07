# User Guide
This user guide describes the basic structures and functions to define an optimisation problem, to solve the problem and to analyse the result. If you want to use `JuMP` to describe the problem, see the [JuMP Interface](@ref) section.

COSMO solves optimisation problems in the following format:
```math
\begin{array}{ll} \mbox{minimize} & \textstyle{\frac{1}{2}}x^\top Px + q^\top x\\ \mbox{subject to} & Ax + s = b \\ & s \in \mathcal{K}, \end{array}
```

with decision variables ``x \in \mathbb{R}^n``, ``s \in \mathbb{R}^m`` and data matrices ``P=P^\top \succeq 0``, ``q \in \mathbb{R}^n``, ``A \in \mathbb{R}^{m \times n}``, and ``b \in \mathbb{R}^m``. The convex set ``\mathcal{K}``
 is a composition of convex sets and cones.

## Model
The problem data, user settings and workspace variables are all stored in a `Model`. To get started define an empty model:
```julia
model = COSMO.Model()
```
To initialize the model with an optimisation problem we need to define three more things:
* the objective function, i.e. the matrix `P` and the vector `q` in ``\frac{1}{2}x^\top P x + q^\top x``
* an array of constraints
* a `Settings` object that specifies how COSMO solves the problem _(optional)_

## Objective Function
To set the objective function of your optimisation problem simply define the square positive semidefinite matrix ``P \in \mathrm{R}^{n\times n} `` and the vector ``q \in \mathrm{R}^{n}``. You might have to transform your optimisation problem into a solver compatible format for this step.

## Constraints
The COSMO interface expects constraints to have the form ``A_i x + b_i \in \mathcal{K}_i``, where ``\mathcal{K}_i`` is one of the convex sets defined below:

Convex Set | Description
--- | ---
ZeroSet | The set ``\{ 0 \}^{dim}`` that contains the origin
Nonnegatives | The nonnegative orthant ``\{ x \in \mathbb{R}^{dim} : x_i \ge 0, \forall i=1,\dots,\mathrm{dim} \}``
Box(u, l) | The hyperbox ``\{ x \in \mathbb{R}^{dim} : l \leq x \leq u\}`` with vectors ``l \in \mathbb{R}^{dim} \cup \{-\infty\}`` and ``u \in \mathbb{R}^{dim} \cup \{+\infty\}``
SecondOrderCone | The second-order (Lorenz) cone ``\{ (t,x) \in \mathbb{R}^{dim}  :  \|x\|_2   \leq t \}``
PsdCone | The vectorized positive semidefinite cone ``\mathcal{S}_+^{dim}``. ``x`` is the vector obtained by stacking the columns of the positive semidefinite matrix ``X``, i.e. ``X \in \mathbb{S}^{\sqrt{dim}}_+ \Rightarrow \text{vec}(X) = x \in \mathcal{S}_+^{dim}``
PsdConeTriangle | The vectorized positive semidefinite cone ``\mathcal{S}_+^{dim}``. ``x`` is the vector obtained by stacking the columns of the upper triangular part of the positive semidefinite matrix ``X``, i.e. ``X \in \mathbb{S}^{d}_+ \Rightarrow \text{svec}(X) = x \in \mathcal{S}_+^{dim}`` where ``d=\sqrt{1/4 + 2 \text{dim}} - 1/2``

The constructor for a constraint expects a matrix `A`, a vector `b` and a `convex_set`.

Lets consider a problem with a decision variable ``x \in \mathbb{R}^5``. Suppose we want to create the two constraint ``x_2 + 5 \geq 0`` and ``x_3 - 3 \geq 0``. We can do this either by creating two constraints and adding them to an array:
```julia
  constraint1 = COSMO.Constraint([0.0 1.0 0.0 0.0 0.0], 5.0, COSMO.Nonnegatives)
  constraint2 = COSMO.Constraint([0.0 0.0 1.0 0.0 0.0], -3.0, COSMO.Nonnegatives)
  constraints = [constraint1; constraint2]
```
The second option is to include both in one constraint:
```julia
constraint1 = COSMO.Constraint([0.0 1.0 0.0 0.0 0.0; 0.0 0.0 1.0 0.0 0.0], [5.0; -3.0], COSMO.Nonnegatives)
```
Another way to construct the constraint is to used the optional arguments `dim`, the dimension of `x`, and `indices`, the elements of `x` that appear in the constraint. When specifying these arguments, `A` and `b` only refer to the elements of `x` in `indices`:
```julia
constraint1 = COSMO.Constraint([1.0 0.0; 0.0 1.0], [5.0; -3.0], COSMO.Nonnegatives, 5, 2:3)
```
Consider as a second example the positive semidefinite constraint on a matrix ``X \in  \mathbb{S}_+^{3}``. Our decision variable is the vector ``x`` obtained by stacking the columns of ``X``. We can specify the constraint on ``x`` in the following way:
```math
I_9 x + \{0\}_9 \in \mathcal{S}_+^9,
```
or in Julia:
```julia
constraint1 = COSMO.Constraint(Matrix(1.0I, 9, 9), zeros(9), COSMO.PsdCone)
```

Several constraints can be combined in an array:
```julia
constraints = [constraint_1, constraint_2, ..., constraint_N]
```

## Settings

The solver settings are stored in a `Settings` object and can be adjusted by the user. To create a `Settings` object just call the constructor:
```julia
settings = COSMO.Settings()
```
The settings object holds the following options and default values:

Argument | Description | Values (default)
--- | --- | ---
rho | ADMM rho step | 0.1
sigma | ADMM sigma step | 1e-6
alpha | Relaxation parameter | 1.6
eps_abs | Absolute residual tolerance | 1e-4
eps_rel | Relative residual tolerance | 1e-4
eps\_prim\_inf | Primal infeasibility tolerance | 1e-4
eps\_dual\_inf | Dual infeasibility tolerance | 1e-4
max_iter | Maximum number of iterations | 2500
verbose | Verbose printing | false
verbose_timing | Verbose timing | false
check_termination | Check termination interval | 40
check_infeasibility | Check infeasibility interval | 40
scaling | Number of scaling iterations | 10
adaptive_rho | Automatic adaptation of step size parameter | true
time_limit | set solver time limit in s | 0.0

To adjust those values, either pass your preferred option and parameter as a key-value pair to the constructor or edit the corresponding field afterwards. For example if you want to enable verbose printing and increase the solver accuracy, you can type
```julia
settings = COSMO.Settings(verbose = true, eps_abs = 1e-5, eps_rel = 1e-5)
# the following is equivalent
settings = COSMO.Settings()
settings.verbose = true
settings.eps_abs = 1e-5
settings.eps_rel = 1e-5
```

## Assembling the model
Once the objective function and an array of constraints have been defined, we can assemble the model with
```julia
COSMO.assemble!(model, P, q, constraints)
```
This simply sets the corresponding variables in the model and transforms the array of constraints into the problem format defined at the top of the page.

If you want to change the default settings, you can pass your settings object `custom_settings` to the `assemble!` function:
```julia
COSMO.assemble!(model, P, q, constraints, settings = custom_settings)
```

## Warm starting
One of the advantages of ADMM-based solvers is that they can be easily warm started. By providing starting values for the primal variable `x` and/or the dual variable `y` in the vicinity of their optimal values, the number of iterations to convergence can often be dramatically decreased.

Consider the case where you have a decision variable ``x \in \mathbb{R}^3`` and a dual variable ``y \in \mathbb{R}^2``. Assume you expect their optimal values to be close to ``x_0 = (1, 5, 3)`` and ``y_0 = (1, 2)``. You can pass these values when assembling the model.
```julia
x_0 = [1.0; 5.0; 3.0]
y_0 = [1.0; 2.0]
COSMO.assemble!(model, P, q, constraints, x0 = x_0, y0 = y_0)
```
Another option is to use
```julia
COSMO.assemble!(model, P, q, constraints)
warm_start_primal!(model, x_0)
warm_start_dual!(model, y_0)
```

## Solving
After the model has been assembled, we can solve the problem by typing
```julia
results = COSMO.optimize!(model)
```
Once the solver algorithm terminates, it will return a `Results` object that gives information about the status of the solver. If successful, it contains the optimal objective value and optimal primal and dual variables. For more information see the following section.

## Results

After attempting to solve the problem, COSMO will return a result object with the following fields:

Fieldname | Type | Description
---  | --- | ---
x | Vector{Float64}| Primal variable
y | Vector{Float64}| Dual variable
s | Vector{Float64}| (Primal) set variable
obj_val | Float64 | Objective value
iter | Int64 | Number of iterations
status | Symbol | Solution status
info | COSMO.ResultInfo | Struct with more information
times | COSMO.ResultTimes | Struct with several measured times

### Status Codes

COSMO will return one of the following statuses:

Status Code  | Description
---  | ---
:Solved | An optimal solution was found
:Unsolved | Default value
:Max\_iter\_reached | Solver reached iteration limit (set with `Settings.max_iter`)
:Time\_limit\_reached | Solver reached time limit (set with `Settings.time_limit`)
:Primal\_infeasible | Problem is primal infeasible
:Dual\_infeasible | Problem is dual infeasible

### Timings
If `settings.verbose_timing` is set to `true`, COSMO will report the following times in `result.times`:

Time Name  | Description
---  | ---
solver_time | Total time used to solve the problem
setup_time | Setup time = graph\_time + factor\_time
graph_time | Time used to perform chordal decomposition
factor_time | Time used to factor the system of linear equations
iter_time | Time spent in iteration loop
proj_time | Time spent in projection functions
post_time | Time used for post processing

It holds:
`solver_time` = `setup_time`+ `iter_time` + `post_time`,

`setup_time` = `graph_time`+ `factor_time`,

`proj_time` is a subset of `iter_time`.


