# Antenna Pattern Analysis

MATLAB analysis and comparison of antenna types designed
for drone communication systems operating in the
865–867 MHz ISM band.

## Antennas covered
| Antenna | Gain | VSWR | Best use |
|---------|------|------|----------|
| Half-wave Dipole | 2.15 dBi | <1.5 | Omnidirectional TX |
| Patch | 7.0 dBi | <1.5 | Directional, compact |
| Yagi-Uda (3-el) | 9.0 dBi | <1.5 | Ground station RX |
| LPDA | 10.5 dBi | <1.5 | Wideband, antenna tracker |

## What the script generates
- Figure 1: Polar radiation patterns for all 4 antennas
- Figure 2: Gain comparison bar chart
- Figure 3: VSWR vs frequency (700–1100 MHz)
- Figure 4: Practical range vs RX antenna gain

## CST simulation results
Full electromagnetic simulation was performed in CST
Microwave Studio. Screenshots in `/cst_results/` folder.

## System context
These antennas were designed and validated at
Enercomp Solutions for drone communication systems.
Achieved antenna gain up to 12 dBi, VSWR <1.5,
and radiation efficiency >85% across target bands.

## How to run
1. Open MATLAB
2. Run `antenna_pattern.m`
3. To import real CST data: see comments at
   bottom of the script

## Author
Pranjul Kumar — RF & Embedded Systems Engineer
M.Tech, IIT Jammu | linkedin.com/in/pranjulkumar
