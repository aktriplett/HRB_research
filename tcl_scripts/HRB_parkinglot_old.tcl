# SCRIPT TO RUN A PARKING LOT TEST FOR THE HEIHE RIVER BASIN

# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Setup run name and location
#-----------------------------------------------------------------------------
set runname "HRB_parkinglot_test1"
file mkdir $runname
cd $runname
pfset TopoSlopes.Elevation.FileName ../parflow_input/HRB_DEM.pfb


#-----------------------------------------------------------------------------
# Set Processor topology
#-----------------------------------------------------------------------------
#I set the script to run on 108 cores, total procs is P*Q*R
pfset Process.Topology.P 9
pfset Process.Topology.Q 12
pfset Process.Topology.R 1

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X           0.0
pfset ComputationalGrid.Lower.Y           0.0
pfset ComputationalGrid.Lower.Z           0.0

pfset ComputationalGrid.DX                1000.0
pfset ComputationalGrid.DY                1000.0
pfset ComputationalGrid.DZ                1

pfset ComputationalGrid.NX                404
pfset ComputationalGrid.NY                548
pfset ComputationalGrid.NZ                1


#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names                     "box_input"

#-----------------------------------------------------------------------------
# Domain Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.box_input.InputType      Box
pfset GeomInput.box_input.GeomName      domain

#-----------------------------------------------------------------------------
# Domain Geometry
#-----------------------------------------------------------------------------
pfset Geom.domain.Lower.X                        0.0
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                        0.0

pfset Geom.domain.Upper.X                        404000.0
pfset Geom.domain.Upper.Y                        548000.0
pfset Geom.domain.Upper.Z                        1
pfset Geom.domain.Patches                        "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names                     "domain"

pfset Geom.domain.Perm.Type               Constant
pfset Geom.domain.Perm.Value              0.000001

pfset Perm.TensorType                     TensorByGeom
pfset Geom.Perm.TensorByGeom.Names        "domain"
pfset Geom.domain.Perm.TensorValX         1.0d0
pfset Geom.domain.Perm.TensorValY         1.0d0
pfset Geom.domain.Perm.TensorValZ         1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset SpecificStorage.Type                Constant
pfset SpecificStorage.GeomNames           "domain"
pfset Geom.domain.SpecificStorage.Value   1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------
pfset Phase.Names                         "water"
pfset Phase.water.Density.Type            Constant
pfset Phase.water.Density.Value           1.0
pfset Phase.water.Viscosity.Type          Constant
pfset Phase.water.Viscosity.Value         1.0

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
pfset Phase.RelPerm.Type                  VanGenuchten
pfset Phase.RelPerm.GeomNames             "domain"

pfset Geom.domain.RelPerm.Alpha           3.5
pfset Geom.domain.RelPerm.N               2.0

#-----------------------------------------------------------------------------
# Saturation
#-----------------------------------------------------------------------------
pfset Phase.Saturation.Type               VanGenuchten
pfset Phase.Saturation.GeomNames          "domain"

pfset Geom.domain.Saturation.Alpha        3.5
pfset Geom.domain.Saturation.N            2.
pfset Geom.domain.Saturation.SRes         0.2
pfset Geom.domain.Saturation.SSat         1.0

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
pfset Geom.Porosity.GeomNames             "domain"

pfset Geom.domain.Porosity.Type          Constant
pfset Geom.domain.Porosity.Value         0.01

#-----------------------------------------------------------------------------
# Mannings coefficient
#-----------------------------------------------------------------------------
pfset Mannings.Type                                   "Constant"
pfset Mannings.GeomNames                              "domain"
pfset Mannings.Geom.domain.Value                      5.52e-6

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names                  ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------
pfset Gravity                             1.0


#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------
pfset Domain.GeomName                     "domain"

#----------------------------------------------------------------------------
# Mobility
#----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                         ""


#-----------------------------------------------------------------------------
# Timing (time units is set by units of permeability)
#-----------------------------------------------------------------------------
pfset TimingInfo.BaseUnit                 1.0
pfset TimingInfo.StartCount               0.0
pfset TimingInfo.StartTime                0.0
pfset TimingInfo.StopTime                 100.0
pfset TimingInfo.DumpInterval             -1
pfset TimeStep.Type                       Constant
pfset TimeStep.Value                      1.0

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names "constant rainrec"

# Constant
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      10000000
pfset Cycle.constant.Repeat             -1

pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           10
pfset Cycle.rainrec.rec.Length            20
pfset Cycle.rainrec.Repeat                14
#use CONUS example not this LW for updated settings, rain only once and recess longer
#overland flow kinematic not overland flow


#-----------------------------------------------------------------------------
# Boundary Conditions
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type		      FluxConst
pfset Patch.x-lower.BCPressure.Cycle		      "constant"
pfset Patch.x-lower.BCPressure.alltime.Value	      0.0

pfset Patch.y-lower.BCPressure.Type		      FluxConst
pfset Patch.y-lower.BCPressure.Cycle		      "constant"
pfset Patch.y-lower.BCPressure.alltime.Value	      0.0

pfset Patch.z-lower.BCPressure.Type		      FluxConst
pfset Patch.z-lower.BCPressure.Cycle		      "constant"
pfset Patch.z-lower.BCPressure.alltime.Value	      0.0

pfset Patch.x-upper.BCPressure.Type		      FluxConst
pfset Patch.x-upper.BCPressure.Cycle		      "constant"
pfset Patch.x-upper.BCPressure.alltime.Value	      0.0

pfset Patch.y-upper.BCPressure.Type		      FluxConst
pfset Patch.y-upper.BCPressure.Cycle		      "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	      0.0

pfset Patch.z-upper.BCPressure.Type		      OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		      "constant"
pfset Patch.z-upper.BCPressure.alltime.Value	      -2.1e-05

pfset Patch.z-upper.BCPressure.Type		      OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		      "rainrec"
pfset Patch.z-upper.BCPressure.rain.Value	      -0.005
pfset Patch.z-upper.BCPressure.rec.Value	      0.00000

#-----------------------------------------------------------------------------
# Topo slopes in x-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            "../parflow_input/slopexPF.pfb"

#-----------------------------------------------------------------------------
# Topo slopes in y-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            "../parflow_input/slopeyPF.pfb"

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         "Constant"
pfset PhaseSources.water.GeomNames                    "domain"
pfset PhaseSources.water.Geom.domain.Value            0.0

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      1.005

pfset ICPressure.GeomNames                              "domain"
pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   z-lower


#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
pfset KnownSolution                                   NoKnownSolution

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------
# ParFlow Solution
pfset Solver                                          Richards
pfset Solver.TerrainFollowingGrid                     True
pfset Solver.Nonlinear.VariableDz                     False

##Do these next parts go here?
#pfset dzScale.GeomNames                               Domain
#pfset dzScale.InputType                               nzList
#pfset dzScale.nzListNumber                            15

#15 layers, 0 for bottom to 15 at the top (do they mean domain or parflow "bottom")
#layers are .1,.4,1,2,12,22,52,82,112,142,172,272,372,472,1072
#But I give PF the depth to cell center here?
#pfset Cell.0.dzScale.Value                            772.0
#pfset Cell.1.dzScale.Value                            422.0
#pfset Cell.2.dzScale.Value                            322.0
#pfset Cell.3.dzScale.Value                            222.0
#pfset Cell.4.dzScale.Value                            157.0
#pfset Cell.5.dzScale.Value                            127.0
#pfset Cell.6.dzScale.Value                            97.0
#pfset Cell.7.dzScale.Value                            67.0
#pfset Cell.8.dzScale.Value                            37.0
#pfset Cell.9.dzScale.Value                            17.0
#pfset Cell.10.dzScale.Value                           7.0
#pfset Cell.11.dzScale.Value                           1.5
#pfset Cell.12.dzScale.Value                           .7
#pfset Cell.13.dzScale.Value                           .25
#pfset Cell.14.dzScale.Value                           .05

pfset Solver.MaxIter                                  25000
pfset Solver.Drop                                     1E-20
pfset Solver.AbsTol                                   1E-8
pfset Solver.MaxConvergenceFailures                   8

pfset Solver.Nonlinear.MaxIter                        80
pfset Solver.Nonlinear.ResidualTol                    1e-6
pfset Solver.Nonlinear.EtaChoice                      EtaConstant
pfset Solver.Nonlinear.EtaValue                       0.001
pfset Solver.Nonlinear.UseJacobian                    True
pfset Solver.Nonlinear.DerivativeEpsilon              1e-16
pfset Solver.Nonlinear.StepTol				 		            1e-30
pfset Solver.Nonlinear.Globalization                  LineSearch

pfset Solver.Linear.KrylovDimension                   70
pfset Solver.Linear.MaxRestarts                       2
pfset Solver.Linear.Preconditioner                    PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType       FullJacobian

pfset Solver.PrintMannings                            True
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.PrintMask                                True
pfset Solver.WriteSiloSubsurfData 					          True
pfset Solver.WriteSiloPressure 						            True
pfset Solver.WriteSiloSaturation 					            True
pfset Solver.WriteSiloSlopes      					          True

#-----------------------------------------------------------------------------
# Distribute inputs
#-----------------------------------------------------------------------------
pfdist -nz 1 ../parflow_input/slopexPF.pfb
pfdist -nz 1 ../parflow_input/slopeyPF.pfb



#-----------------------------------------------------------------------------
# Run Simulation
#-----------------------------------------------------------------------------
puts     $runname
pfrun    $runname

#-----------------------------------------------------------------------------
# Undistribute outputs
#-----------------------------------------------------------------------------
pfundist $runname
pfundist ../parflow_input/slopexPF.pfb
pfundist ../parflow_input/slopeyPF.pfb


puts "ParFlow run Complete"
