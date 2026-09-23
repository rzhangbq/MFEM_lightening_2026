# MFEM PIC lightning talk — speaker script

Target: about 10 minutes; the Q&A slide follows the talk.

## 1. Particle-in-cell in MFEM

0:00–0:20. I will show how we extend particle tracing in MFEM to an electrostatic particle-in-cell simulation. The new ingredient is feedback: particle positions determine charge on the mesh, and the resulting electric field moves those same particles. I will focus on what we added to the implementation, then show validation and parallel scaling.

## 2. Particle tracing in MFEM

0:20–0:45. This is the particle-tracing work presented at last year's MFEM workshop by Joseph Signorelli, Ketan Mittal, and Tzanio Kolev. Their particle infrastructure is the starting point for our PIC work. In particular, it already handles mesh localization, field evaluation at particle positions, particle motion, and transfer between MPI ranks.

## 3. Particle tracing in MFEM

0:45–1:45. Here is an example of particles moving in a Tokamak field. Particle tracing gives us a particle class with position, momentum, mass, and charge. It locates particles in the mesh, interpolates the field at their positions (specifically, it finds the finite element that a particle is in and evaluates the field at that point.), uses the Boris push to update position and momentum, and redistributes particles when they cross MPI subdomains. [Pause for the animation.] In this tracing example, the field is given. The particles follow it, but they do not change it. That missing direction of coupling is what PIC adds.

## 4. The natural next step: particle-in-cell

1:45–2:05. The natural next step is to close the loop. We deposit particle charge onto the finite element mesh, solve for an electric field, and use that field to advance the particles. Then we repeat. This changes tracing into a self-consistent particle-in-cell simulation.

## 5. Governing Equations

2:05–3:00. Here is the mathematical model behind that loop. The Vlasov equation evolves a distribution in position and velocity. Rather than storing the full distribution on a phase-space grid, we represent it with macro-particles. In this implementation every particle has weight one, so there is no separate particle-weight factor in the sum. When we integrate the distribution over velocity, each particle contributes a point charge at its current position. Adding these contributions gives the charge density on the right-hand side of Poisson's equation.

## 6. Governing Equations

3:00–3:45. Charge is the source for the electrostatic potential. In the weak Poisson equation, a point charge contributes the test-function value at its particle position. The background term balances the reference charge. With periodic boundaries, adding a constant to the potential does not change the field, so the Poisson operator has a constant nullspace. We use OrthoSolver to remove that mode and select a potential representative.

## 7. Governing Equations

3:45–4:25. Once we have the potential, the electric field is its negative gradient. The weak equation at the top states that relationship in the H-curl space. As a remark, the diagram shows why the spaces are compatible: the gradient maps H-one functions into H-curl fields, and MFEM preserves that connection between continuous Galerkin and Nédélec spaces. That compatible gradient is why total energy can be shown to be conserved in the discrete PIC system. This is the mesh field we then evaluate at particle positions.

## 8. One PIC time step in MFEM

4:25–5:40. These are the six operations in one time step. First, we deposit charge by evaluating the H-one test functions at particle positions. Second, we solve the periodic Poisson system with OrthoSolver. Third, we compute the electric field as the negative gradient of the potential, and fourth, we gather that field at each particle. Fifth, we push the particles. The equations show the staggered leapfrog update: momentum advances by the electric force, then position advances using the new half-step momentum. This is the electrostatic push used here; the tracing example on the earlier slide showed a Boris push for its prescribed field. Finally, we redistribute any particle that crossed an MPI subdomain boundary. At the next step, those new positions produce a new charge density.

## 9. Validation: linear Landau damping

5:40–6:40. We validate the field-particle coupling with linear Landau damping. The initial perturbation creates an electric field, and the field-energy oscillations decay over time. The dashed line gives the reference damping envelope; the simulated envelope follows it closely in this large run. This case uses 256 MPI ranks with 20,000 particles on each rank, a 64-by-64 mesh, and 400 steps at delta t equal to 0.05. The point of this plot is that deposition, the Poisson solve, gathering, and particle motion together reproduce the expected damping behavior.

## 10. Total energy in the validation run

6:40–7:20. These plots are another check from the same run. Both are normalized by the initial total energy. On the left, kinetic and field energy exchange as the plasma evolves, while the orange total stays nearly flat. On the right, that total is shown more closely, so the vertical scale is only a few ten-thousandths. The blue curve oscillates and the dashed fit shows a small drift. Total energy stays close to its initial value throughout the run. I am using this as a numerical diagnostic here; I will leave the detailed structure analysis for another talk.

## 11. Parallel scaling

7:20–8:50. We also tested parallel scaling on NERSC from 8 to 128 MPI ranks. On the left is weak scaling: we keep 40,960 particles per rank, so the total particle count grows with the rank count. Ideal efficiency would stay at one; the measured value decreases to about 0.56 at 128 ranks. On the right is strong scaling: we hold 2,621,440 particles fixed. The speedup reaches about 6.4 at 128 ranks, with efficiency around 0.4. The field solve and particle redistribution both contribute to the cost as ranks increase. Both studies use a 64-by-64 mesh and 400 steps at delta t equal to 0.05.

## 12. Summary

8:50–9:45. To summarize, we have built a scalable electrostatic PIC implementation in MFEM. The linear Landau damping result checks the coupled particle and field calculation, while the scaling studies show how the implementation performs across MPI ranks. Our ongoing work is GPU support for charge deposition, field gathering, and the particle push. Eddy Luo and Elliot Day are presenting a poster on that GPU work, so please visit them for more detail. Thank you.

## 13. Questions?

9:45 onward. I am happy to take questions. The video shows a two-stream PIC simulation and can run while we discuss the method or implementation.
