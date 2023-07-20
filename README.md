    Copyright(c) 2022-
    Author: Chaitanya Tejaswi (github.com/CRTejaswi)    License: GPL v3.0+

# FPGA: Floating Pt Square-Root
> 32bit integer square-root (restoring divison) & 32bit floating-pt square-root (newton-raphson) implementations on FPGA.

# Implementations

## [32bit integer sqrt](root_restoring.v):
__Documentation__: [📄](docs/v1.pdf) <br>
__Reports__: [timing](v1/reports/timing.txt), [power](v1/reports/power.txt) <br>
__Approach__: <br>
<img src="files/v1.png" width="720" title="Approach">

__Results__ <br>

<!-- <img src="v1/files/schematic1.png" width="720" title="RTL Schematic"><br> -->
<!-- <img src="v1/files/schematic2.png" width="720" title="RTL Schematic"><br> -->
<img src="files/sim1.png" width="720" title="Simulation: Testbench Evaluation"><br>
<!-- <img src="v1/files/sim1.png" width="720" title="Simulation: SLL, SLT/SLTU<br>, SRL/SRA"><br> -->
<!-- <img src="v1/files/usage1.png" width="720" title="Usage: Power/Timing"><br> -->
<!-- <img src="v1/files/usage2.png" width="720" title="Usage: FPGA"><br> -->


## [32bit floating-pt: ](root_newton.v):
__Documentation__: [📄](docs/v2.pdf) <br>
__Reports__: [timing](v2/reports/timing.txt), [power](v2/reports/power.txt) <br>
__Approach__: <br>
Result is accumulated using `X[i+1] = Xi * (3 - Xi * Xi * d) / 2`. `1/sqrt(N)` is obtained from a pre-calculated LUT. This approach is the fastest; consumes lesser area too.
<img src="files/v2.png" width="720" title="Approach">

__Results__ <br>

<!-- <img src="v1/files/schematic1.png" width="720" title="RTL Schematic"><br> -->
<!-- <img src="v1/files/schematic2.png" width="720" title="RTL Schematic"><br> -->
<img src="files/sim2a.png" width="720" title="Simulation: Testbench Evaluation"><br>
<img src="files/sim2b.png" width="720" title="Simulation: Testbench Evaluation"><br>
<!-- <img src="v1/files/sim1.png" width="720" title="Simulation: SLL, SLT/SLTU<br>, SRL/SRA"><br> -->
<!-- <img src="v1/files/usage1.png" width="720" title="Usage: Power/Timing"><br> -->
<!-- <img src="v1/files/usage2.png" width="720" title="Usage: FPGA"><br> -->


## [32bit floating-pt: ](sqrt.v):

__Documentation__: [📄](docs/v3.pdf) <br>
__Reports__: [timing](v3/reports/timing.txt), [power](v3/reports/power.txt) <br>
__Approach__: <br>
(alternative approach) Result is accumulated using 4 stages - 3 iterations for partial sums, 1 for normalizing values to fit IEEE754 format (ie, multiply by √2 if E is odd ). The approach/partial sums are listed below:
<img src="files/v3.png" width="720" title="Approach">

__Results__ <br>

<img src="files/schematic3.png" width="720" title="RTL Schematic"><br>
<img src="files/sim3.png" width="720" title="Simulation: Testbench Evaluation"><br>
<!-- <img src="v1/files/sim1.png" width="720" title="Simulation: SLL, SLT/SLTU<br>, SRL/SRA"><br> -->
<!-- <img src="v1/files/usage1.png" width="720" title="Usage: Power/Timing"><br> -->
<!-- <img src="v1/files/usage2.png" width="720" title="Usage: FPGA"><br> -->

# References
