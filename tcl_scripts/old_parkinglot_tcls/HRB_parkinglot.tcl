# SCRIPT TO RUN A PARKING LOT TEST FOR THE HEIHE RIVER BASIN
#  similar to that in Kollet and Maxwell (2006) AWR

set tcl_precision 17

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4

#-----------------------------------------------------------------------------
# Setup run name and location
#-----------------------------------------------------------------------------
set runname "HRB_parkinglot_test"
file mkdir $runname
cd $runname

#-----------------------------------------------------------------------------
# Set Processor topology
#-----------------------------------------------------------------------------
#I set the script to run on 432 cores, total procs is P*Q*R

pfset Process.Topology.P                      18
pfset Process.Topology.Q                      24
pfset Process.Topology.R                      1

#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
pfset ComputationalGrid.Lower.X                0.0
pfset ComputationalGrid.Lower.Y                0.0
pfset ComputationalGrid.Lower.Z                0.0

pfset ComputationalGrid.NX                     404
pfset ComputationalGrid.NY                     548
pfset ComputationalGrid.NZ                     1

pfset ComputationalGrid.DX	                   1000.0
pfset ComputationalGrid.DY                     1000.0
pfset ComputationalGrid.DZ	                   1.0

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------
pfset GeomInput.Names                          "domaininput"

pfset GeomInput.domaininput.GeomName            domain

pfset GeomInput.domaininput.InputType           SolidFile
pfset GeomInput.domaininput.GeomNames           domain
pfset GeomInput.domaininput.FileName            "../parflow_input/HRB_domain_init.pfsol"

pfset Geom.domain.Patches                       "left right front back bottom top"
#order needs need to match the number assigned in the solid file creation




#--------------------------------------------
# variable dz assignments
#------------------------------------------
pfset Solver.Nonlinear.VariableDz               False
#pfset dzScale.GeomNames                        domain
#pfset dzScale.Type                             nzList
#pfset dzScale.nzListNumber                     1

#pfset dzScale.Type                             nzList
#pfset dzScale.nzListNumber                     3
#pfset Cell.0.dzScale.Value                     0.0001

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names                           "domain"


pfset Geom.domain.Perm.Type                      Constant
pfset Geom.domain.Perm.Value                     0.000001

pfset Perm.TensorType                            TensorByGeom

pfset Geom.Perm.TensorByGeom.Names               "domain"

pfset Geom.domain.Perm.TensorValX                1.0d0
pfset Geom.domain.Perm.TensorValY                1.0d0
pfset Geom.domain.Perm.TensorValZ                1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------

pfset SpecificStorage.Type                       Constant
pfset SpecificStorage.GeomNames                  "domain"
pfset Geom.domain.SpecificStorage.Value          1.0e-4

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names                                 "water"

pfset Phase.water.Density.Type	                   Constant
pfset Phase.water.Density.Value	                   1.0

pfset Phase.water.Viscosity.Type	                 Constant
pfset Phase.water.Viscosity.Value	                 1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------

pfset Contaminants.Names			                      ""

#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------

pfset Geom.Retardation.GeomNames                    ""

#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                                   ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				                                1.0

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames                       "domain"

pfset Geom.domain.Porosity.Type                     Constant
pfset Geom.domain.Porosity.Value                    0.00000001

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type                            VanGenuchten
pfset Phase.RelPerm.GeomNames                       "domain"

pfset Geom.domain.RelPerm.Alpha                     1.0
pfset Geom.domain.RelPerm.N                         2.0

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type                         VanGenuchten
pfset Phase.Saturation.GeomNames                    "domain"

pfset Geom.domain.Saturation.Alpha                  1.0
pfset Geom.domain.Saturation.N                      2.0
pfset Geom.domain.Saturation.SRes                   0.2
pfset Geom.domain.Saturation.SSat                   1.0

#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------

pfset Mannings.Type                                  "Constant"
pfset Mannings.GeomNames                             "domain"
pfset Mannings.Geom.domain.Value                     2.e-6
pfset Mannings.Geom.domain.Value                     0.0000044

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value            0.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------

#
pfset TimingInfo.BaseUnit                           1.0
pfset TimingInfo.StartCount                         0
pfset TimingInfo.StartTime                          0.0
pfset TimingInfo.StopTime                           50.0
pfset TimingInfo.DumpInterval                       -1
pfset TimeStep.Type                                 Constant
pfset TimeStep.Value                                1.0


#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName                               domain


#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names                                   "constant rainrec"
pfset Cycle.constant.Names                          "alltime"
pfset Cycle.constant.alltime.Length                 1
pfset Cycle.constant.Repeat                         -1

# rainfall and recession time periods are defined here
# rain for 1 hour, recession for 2 hours

pfset Cycle.rainrec.Names                           "rain rec"
pfset Cycle.rainrec.rain.Length                     5
pfset Cycle.rainrec.rec.Length                      300
pfset Cycle.rainrec.Repeat                          -1


#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------

pfset KnownSolution                                    NoKnownSolution


#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------

pfset Solver                                             Richards
pfset Solver.MaxIter                                     2500

pfset Solver.Nonlinear.MaxIter                           50
pfset Solver.Nonlinear.ResidualTol                       1e-6
#pfset Solver.Nonlinear.ResidualTol                       1e-7

pfset Solver.Nonlinear.EtaChoice                         EtaConstant

pfset Solver.Nonlinear.EtaValue                          0.01
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				                   1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      20
pfset Solver.Linear.MaxRestart                           2

pfset Solver.Linear.Preconditioner                       PFMGOctree
#pfset Solver.Linear.Preconditioner                      PFMG

pfset Solver.PrintSubsurf				                         False
pfset  Solver.Drop                                       1E-30
pfset Solver.AbsTol                                      1E-9

#pfset Solver.WriteSiloSubsurfData                       True
#pfset Solver.WriteSiloPressure                          True
#pfset Solver.WriteSiloSlopes                            True
#
#pfset Solver.WriteSiloSaturation                        True
#pfset Solver.WriteSiloConcentration                     True

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      0.0

pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   bottom


#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

#no flow boundaries for the left, right, front, back and bottom boundaries
pfset Patch.left.BCPressure.Type		                     FluxConst
pfset Patch.left.BCPressure.Cycle		                     "constant"
pfset Patch.left.BCPressure.alltime.Value	               0.0

pfset Patch.right.BCPressure.Type		                     FluxConst
pfset Patch.right.BCPressure.Cycle		                   "constant"
pfset Patch.right.BCPressure.alltime.Value	             0.0

pfset Patch.front.BCPressure.Type		                     FluxConst
pfset Patch.front.BCPressure.Cycle		                   "constant"
pfset Patch.front.BCPressure.alltime.Value	             0.0

pfset Patch.back.BCPressure.Type		                     FluxConst
pfset Patch.back.BCPressure.Cycle		                     "constant"
pfset Patch.back.BCPressure.alltime.Value	               0.0

pfset Patch.bottom.BCPressure.Type		                   FluxConst
pfset Patch.bottom.BCPressure.Cycle		                   "constant"
pfset Patch.bottom.BCPressure.alltime.Value	             0.0


## overland flow boundary condition with rainfall then nothing
pfset Patch.top.BCPressure.Type		                       OverlandKinematic
pfset Patch.top.BCPressure.Cycle		                     "rainrec"
pfset Patch.top.BCPressure.rain.Value	                   -0.05
pfset Patch.top.BCPressure.rec.Value	                   0.0000

pfset Solver.Nonlinear.UseJacobian                       False
pfset Solver.Linear.Preconditioner.PCMatrixType          PFSymmetric


#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------

#----------------1----------------------
#set runname "HRB_parkinglot_test"
#file mkdir $runname
#cd $runname

#file copy -force "../gaussian_Str3.ep0.rvth100.mx0.5.mn4.secNA.stan_slopex.pfb" .
#file copy -force "../gaussian_Str3.ep0.rvth100.mx0.5.mn4.secNA.stan_slopey.pfb" .
#file copy -force "../parflow_input/HRB_domain_init.pfsol"   .
#file copy -force "../CONUS2.0_Parkinglot_Kine_new3.tcl"   .

pfset TopoSlopesX.Type                                  "PFBFile"
pfset TopoSlopesX.GeomNames                             "domain"
pfset TopoSlopesX.FileName                              "../parflow_input/slopexPF.pfb"
pfdist                                                  -nz 1 ../parflow_input/slopexPF.pfb

pfset TopoSlopesY.Type                                  "PFBFile"
pfset TopoSlopesY.GeomNames                             "domain"
pfset TopoSlopesY.FileName                              "../parflow_input/slopeyPF.pfb"
pfdist                                                  -nz 1 ../parflow_input/slopeyPF.pfb

puts $runname

pfrun $runname
pfundist $runname
#cd ..
pfundist ../parflow_input/slopexPF.pfb
pfundist ../parflow_input/slopeyPF.pfb



#
#pfwritedb $runname
#exit
#pfundist $runname
#cd ../
