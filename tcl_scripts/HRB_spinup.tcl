# SCRIPT TO RUN HEIHE RIVER BASIN DOMAIN WITH TERRAIN-FOLLOWING GRID
# DETAILS:
# Arugments are 1) runname 2) year

# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Setup run name and location
#-----------------------------------------------------------------------------
set runname "HRB_spinup1"
file mkdir $runname
cd $runname
pfset TopoSlopes.Elevation.FileName ../MY DEM.pfb

#-----------------------------------------------------------------------------
# Set Processor topology
#-----------------------------------------------------------------------------
pfset Process.Topology.P 1 #need to change when running on Cheyenne
pfset Process.Topology.Q 1
pfset Process.Topology.R 1

#-----------------------------------------------------------------------------
# Make a directory for the simulation and copy inputs into it
#-----------------------------------------------------------------------------
exec mkdir "Outputs"
cd "./Outputs"
# ParFlow Inputs
file copy -force "../../parflow_input/HRB.slopex.pfb" .
file copy -force "../../parflow_input/HRB.slopey.pfb" .
file copy -force "../../parflow_input/MY INDICATOR FILE.pfb"
file copy -force "../../parflow_input/press.init.pfb"  .

puts "Files Copied"

#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X           0.0
pfset ComputationalGrid.Lower.Y           0.0
pfset ComputationalGrid.Lower.Z           0.0

pfset ComputationalGrid.DX                1000.0
pfset ComputationalGrid.DY                1000.0
pfset ComputationalGrid.DZ                600.0 #Not sure what this value should be when variable dz
#being multiplied by this comp dz for var dz
pfset ComputationalGrid.NX                404
pfset ComputationalGrid.NY                548
pfset ComputationalGrid.NZ                15


#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names                     "box_input indi_input"

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
pfset Geom.domain.Upper.Z                        1072.0 #total depth in z #NZ * DZ
pfset Geom.domain.Patches                        "x-lower x-upper y-lower y-upper z-lower z-upper"

#-----------------------------------------------------------------------------
# Indicator Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.indi_input.InputType      IndicatorField
pfset GeomInput.indi_input.GeomNames      "k1 k2 k3 k4 k5 k6 k7 k8 k9 k10 ss1 ss2 sy 1 vka1"
pfset Geom.indi_input.FileName            "../PATH TO MY INDICATOR FILE.pfb"
#for now just do Ks
pfset GeomInput.k1.Value                1
pfset GeomInput.k2.Value                2
pfset GeomInput.k3.Value                3
pfset GeomInput.k4.Value                4
pfset GeomInput.k5.Value                5
pfset GeomInput.k6.Value                6
pfset GeomInput.k7.Value                7
pfset GeomInput.k8.Value                8
pfset GeomInput.k9.Value                9
pfset GeomInput.k10.Value               10
pfset GeomInput.ss1.Value               100
pfset GeomInput.ss2.Value               101
pfset GeomInput.sy1.Value               200
pfset GeomInput.sy3.Value               201
pfset GeomInput.sy4.Value               202
pfset GeomInput.sy5.Value               203
pfset GeomInput.sy6.Value               204
pfset GeomInput.sy7.Value               205
pfset GeomInput.sy8.Value               206
pfset GeomInput.sy9.Value               207
pfset GeomInput.sy10.Value              208
pfset GeomInput.vka1.Value              300
pfset GeomInput.vka1.Value              301
pfset GeomInput.vka2.Value              302
pfset GeomInput.vka3.Value              303
pfset GeomInput.vka4.Value              304
pfset GeomInput.vka5.Value              305
pfset GeomInput.vka6.Value              306
pfset GeomInput.vka7.Value              307
pfset GeomInput.vka8.Value              308
pfset GeomInput.vka9.Value              309
pfset GeomInput.vka10.Value             310


#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
#these are my K values I assume
pfset Geom.Perm.Names                     "domain k1 k2 k3 k4 k5 k6 k7 k8 k9 k10"
#Write an r script to write this paste names
pfset Geom.domain.Perm.Type           Constant
pfset Geom.domain.Perm.Value          0.0

pfset Geom.k1.Perm.Type               Constant
pfset Geom.k1.Perm.Value              0.00083

pfset Geom.k2.Perm.Type               Constant
pfset Geom.k2.Perm.Value              0.00125

pfset Geom.k3.Perm.Type               Constant
pfset Geom.k3.Perm.Value              0.00167

pfset Geom.k4.Perm.Type               Constant
pfset Geom.k4.Perm.Value              0.00208

pfset Geom.k5.Perm.Type               Constant
pfset Geom.k5.Perm.Value              0.00250

pfset Geom.k6.Perm.Type               Constant
pfset Geom.k6.Perm.Value              0.00333

pfset Geom.k7.Perm.Type               Constant
pfset Geom.k7.Perm.Value              0.00417

pfset Geom.k8.Perm.Type               Constant
pfset Geom.k8.Perm.Value              0.00625

pfset Geom.k9.Perm.Type               Constant
pfset Geom.k9.Perm.Value              0.00667

pfset Geom.k10.Perm.Type               Constant
pfset Geom.k10.Perm.Value              0.00833



pfset Perm.TensorType                     TensorByGeom
pfset Geom.Perm.TensorByGeom.Names        "domain"
pfset Geom.domain.Perm.TensorValX         1.0d0
pfset Geom.domain.Perm.TensorValY         1.0d0
pfset Geom.domain.Perm.TensorValZ         1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names                     "domain ss1"

pfset Geom.domain.SpecificStorage.Type   Constant
pfset Geom.domain.Perm.Value             1e-05

pfset Geom.ss1.SpecificStorage.Type      Constant
pfset Geom.ss1.Perm.Value                1e-04

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------
pfset Phase.Names                         "water"
pfset Phase.water.Density.Type            Constant
pfset Phase.water.Density.Value           1.0
pfset Phase.water.Viscosity.Type          Constant
pfset Phase.water.Viscosity.Value         1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names                  ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------
pfset Gravity                             1.0

#-----------------------------------------------------------------------------
# Timing (time units is set by units of permeability)
#-----------------------------------------------------------------------------
pfset TimingInfo.BaseUnit        10.0
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        10000000.0
pfset TimingInfo.DumpInterval    100.0
pfset TimeStep.Type              Growth
pfset TimeStep.InitialStep       1
pfset TimeStep.GrowthFactor      1.1
pfset TimeStep.MaxStep           100
pfset TimeStep.MinStep           1
#pfset TimeStep.Value            1.0

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
##Still need to calculate this, what do I do about layers that don't have an SY value
pfset Geom.Porosity.GeomNames             "domain sy1 sy2 sy3 sy4 sy5 sy6 sy7 sy8 sy9 sy10"

pfset Geom.domain.Porosity.Type          Constant
pfset Geom.domain.Porosity.Value         0.4

pfset Geom.s1.Porosity.Type              Constant
pfset Geom.s1.Porosity.Value             0.375

pfset Geom.s2.Porosity.Type              Constant
pfset Geom.s2.Porosity.Value             0.39

pfset Geom.s3.Porosity.Type              Constant
pfset Geom.s3.Porosity.Value             0.387

pfset Geom.s4.Porosity.Type              Constant
pfset Geom.s4.Porosity.Value             0.439

pfset Geom.s5.Porosity.Type              Constant
pfset Geom.s5.Porosity.Value             0.489

pfset Geom.s6.Porosity.Type              Constant
pfset Geom.s6.Porosity.Value             0.399

pfset Geom.s7.Porosity.Type              Constant
pfset Geom.s7.Porosity.Value             0.384

pfset Geom.s8.Porosity.Type              Constant
pfset Geom.s8.Porosity.Value             0.482

pfset Geom.s9.Porosity.Type              Constant
pfset Geom.s9.Porosity.Value             0.442

pfset Geom.s10.Porosity.Type              Constant
pfset Geom.s10.Porosity.Value             0.442

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
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names                         "constant"
pfset Cycle.constant.Names                "alltime"
pfset Cycle.constant.alltime.Length        1
pfset Cycle.constant.Repeat               -1

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
#pfset Patch.z-upper.BCPressure.alltime.Value	      0.0
# constant recharge at 185 mm / y
pfset Patch.z-upper.BCPressure.alltime.Value         -2.1E-05

#-----------------------------------------------------------------------------
# Topo slopes in x-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            "../parflow_input/HRB.slopex.pfb"

#-----------------------------------------------------------------------------
# Topo slopes in y-direction
#-----------------------------------------------------------------------------
pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            "../parflow_input/HRB.slopey.pfb"

#-----------------------------------------------------------------------------
# Mannings coefficient
#-----------------------------------------------------------------------------
pfset Mannings.Type                                   "Constant"
pfset Mannings.GeomNames                              "domain"
pfset Mannings.Geom.domain.Value                      5.52e-6

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
pfset Phase.RelPerm.Type                  VanGenuchten
pfset Phase.RelPerm.GeomNames             "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 "

pfset Geom.domain.RelPerm.Alpha           3.5
pfset Geom.domain.RelPerm.N               2.0

pfset Geom.s1.RelPerm.Alpha        3.548
pfset Geom.s1.RelPerm.N            4.162

pfset Geom.s2.RelPerm.Alpha        3.467
pfset Geom.s2.RelPerm.N            2.738

pfset Geom.s3.RelPerm.Alpha        2.692
pfset Geom.s3.RelPerm.N            2.445

pfset Geom.s4.RelPerm.Alpha        0.501
pfset Geom.s4.RelPerm.N            2.659

pfset Geom.s5.RelPerm.Alpha        0.661
pfset Geom.s5.RelPerm.N            2.659

pfset Geom.s6.RelPerm.Alpha        1.122
pfset Geom.s6.RelPerm.N            2.479

pfset Geom.s7.RelPerm.Alpha        2.089
pfset Geom.s7.RelPerm.N            2.318

pfset Geom.s8.RelPerm.Alpha        0.832
pfset Geom.s8.RelPerm.N            2.514

pfset Geom.s9.RelPerm.Alpha        1.585
pfset Geom.s9.RelPerm.N            2.413

#-----------------------------------------------------------------------------
# Saturation
#-----------------------------------------------------------------------------
pfset Phase.Saturation.Type               VanGenuchten
pfset Phase.Saturation.GeomNames          "domain s1 s2 s3 s4 s5 s6 s7 s8 s9 "

pfset Geom.domain.Saturation.Alpha        3.5
pfset Geom.domain.Saturation.N            2.
pfset Geom.domain.Saturation.SRes         0.2
pfset Geom.domain.Saturation.SSat         1.0

pfset Geom.s1.Saturation.Alpha        3.548
pfset Geom.s1.Saturation.N            4.162
pfset Geom.s1.Saturation.SRes         0.000001
pfset Geom.s1.Saturation.SSat         1.0

pfset Geom.s2.Saturation.Alpha        3.467
pfset Geom.s2.Saturation.N            2.738
pfset Geom.s2.Saturation.SRes         0.000001
pfset Geom.s2.Saturation.SSat         1.0

pfset Geom.s3.Saturation.Alpha        2.692
pfset Geom.s3.Saturation.N            2.445
pfset Geom.s3.Saturation.SRes         0.000001
pfset Geom.s3.Saturation.SSat         1.0

pfset Geom.s4.Saturation.Alpha        0.501
pfset Geom.s4.Saturation.N            2.659
pfset Geom.s4.Saturation.SRes         0.000001
pfset Geom.s4.Saturation.SSat         1.0

pfset Geom.s5.Saturation.Alpha        0.661
pfset Geom.s5.Saturation.N            2.659
pfset Geom.s5.Saturation.SRes         0.000001
pfset Geom.s5.Saturation.SSat         1.0

pfset Geom.s6.Saturation.Alpha        1.122
pfset Geom.s6.Saturation.N            2.479
pfset Geom.s6.Saturation.SRes         0.000001
pfset Geom.s6.Saturation.SSat         1.0

pfset Geom.s7.Saturation.Alpha        2.089
pfset Geom.s7.Saturation.N            2.318
pfset Geom.s7.Saturation.SRes         0.000001
pfset Geom.s7.Saturation.SSat         1.0

pfset Geom.s8.Saturation.Alpha        0.832
pfset Geom.s8.Saturation.N            2.514
pfset Geom.s8.Saturation.SRes         0.000001
pfset Geom.s8.Saturation.SSat         1.0

pfset Geom.s9.Saturation.Alpha        1.585
pfset Geom.s9.Saturation.N            2.413
pfset Geom.s9.Saturation.SRes         0.000001
pfset Geom.s9.Saturation.SSat         1.0

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         "Constant"
pfset PhaseSources.water.GeomNames                    "domain"
pfset PhaseSources.water.Geom.domain.Value            0.0

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
#Starting from an initial pressure file
#pfset ICPressure.Type                                 PFBFile
#pfset ICPressure.GeomNames                            domain
#pfset Geom.domain.ICPressure.RefPatch                   z-upper
#pfset Geom.domain.ICPressure.FileName                   ../parflow_input/press.init.pfb

# Starting the domain dry
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      0.0
pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   z-lower

#----------------------------------------------------------------
# Outputs
# ------------------------------------------------------------
pfset Solver.WriteSiloSubsurfData 					           True
pfset Solver.WriteSiloPressure 						             True
pfset Solver.WriteSiloSaturation 					             True
pfset Solver.WriteSiloSlopes      					           True
pfset Solver.WriteSiloCLM                              True
pfset Solver.WriteCLMBinary                            False
pfset Solver.WriteSiloMannings                         True
pfset Solver.PrintCLM                                  True


pfset Solver.PrintMannings                             True
pfset Solver.PrintPressure                             True
pfset Solver.PrintSaturation                           True
pfset Solver.PrintMask                                 True
#pfset Solver.PrintCLM                                 True
#pfset Solver.WriteSiloSpecificStorage                 False
#pfset Solver.WriteSiloMannings                        False
#pfset Solver.WriteSiloSubsurfData                     False
#pfset Solver.WriteSiloEvapTrans                       False
#pfset Solver.WriteSiloEvapTransSum                    False
#pfset Solver.WriteSiloOverlandSum                     False



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
pfset Solver.Nonlinear.VariableDz                     True

##Do these next parts go here?
#pfset dzScale.GeomNames                               Domain
#pfset dzScale.InputType                               nzList
#pfset dzScale.nzListNumber                            15

#15 layers, 0 for bottom to 15 at the top (do they mean domain or parflow "bottom")
#layers are .1,.4,1,2,12,22,52,82,112,142,172,272,372,472,1072 (bottom depth)
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

## new solver settings for Terrain Following Grid
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				 			            1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      70
pfset Solver.Linear.MaxRestarts                           2


pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian

pfset OverlandFlowSpinUp  	                             1

#-----------------------------------------------------------------------------
# Distribute inputs
#-----------------------------------------------------------------------------
pfdist -nz 1 ../parflow_input/HRB.slopex.pfb
pfdist -nz 1 ../parflow_input/HRB.slopey.pfb
pfdist ../parflow_input/MY INDICATOR FILE.pfb
#pfdist ../parflow_input/press.init.pfb

#-----------------------------------------------------------------------------
# Run Simulation
#-----------------------------------------------------------------------------
puts $runname
pfrun $runname

#-----------------------------------------------------------------------------
# Undistribute outputs
#-----------------------------------------------------------------------------
pfundist $runname
#pfundist press.init.pfb
pfundist ../parflow_input/HRB.slopex.pfb
pfundist ../parflow_input/HRB.slopey.pfb
pfundist ../parflow_input/MY INDICATOR FILE.pfb

puts "ParFlow run Complete"
