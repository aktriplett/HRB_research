#  This runs the tilted-v catchment problem
#  similar to that in Kollet and Maxwell (2006) AWR

set tcl_precision 17

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4

pfset Process.Topology.P        1
pfset Process.Topology.Q        1
pfset Process.Topology.R        1

#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
pfset ComputationalGrid.Lower.X           0.0
pfset ComputationalGrid.Lower.Y           0.0
pfset ComputationalGrid.Lower.Z           0.0

#pfset ComputationalGrid.NX                4442
#pfset ComputationalGrid.NY                3256
#pfset ComputationalGrid.NZ                1

pfset ComputationalGrid.NX                27
pfset ComputationalGrid.NY                24
pfset ComputationalGrid.NZ                2

pfset ComputationalGrid.DX	         1000.0
pfset ComputationalGrid.DY               1000.0
pfset ComputationalGrid.DZ	            500.0

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------
pfset GeomInput.Names                 "domaininput"

pfset GeomInput.domaininput.GeomName  domain

pfset GeomInput.domaininput.InputType  SolidFile
pfset GeomInput.domaininput.GeomNames  domain
pfset GeomInput.domaininput.FileName   ../Solid_file/SmallTest.pfsol

pfset Geom.domain.Patches             "land top river bottom"

#--------------------------------------------
# variable dz assignments
#------------------------------------------
pfset Solver.Nonlinear.VariableDz   True
pfset dzScale.GeomNames            domain
pfset dzScale.Type            nzList
pfset dzScale.nzListNumber       2
pfset Cell.0.dzScale.Value 1.0
pfset Cell.1.dzScale.Value 0.002


#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names                 "domain"


pfset Geom.domain.Perm.Type            Constant
pfset Geom.domain.Perm.Value           0.3

pfset Perm.TensorType               TensorByGeom

pfset Geom.Perm.TensorByGeom.Names  "domain"

pfset Geom.domain.Perm.TensorValX  1.0d0
pfset Geom.domain.Perm.TensorValY  1.0d0
pfset Geom.domain.Perm.TensorValZ  1.0d0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------

pfset SpecificStorage.Type            Constant
pfset SpecificStorage.GeomNames       "domain"
pfset Geom.domain.SpecificStorage.Value 1.0e-4

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names "water"

pfset Phase.water.Density.Type	        Constant
pfset Phase.water.Density.Value	        1.0

pfset Phase.water.Viscosity.Type	Constant
pfset Phase.water.Viscosity.Value	1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------

pfset Contaminants.Names			""

#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------

pfset Geom.Retardation.GeomNames           ""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity				1.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------

#
pfset TimingInfo.BaseUnit        10.
pfset TimingInfo.StartCount      0
pfset TimingInfo.StartTime       0.0
pfset TimingInfo.StopTime        500000.0
#pfset TimingInfo.StopTime        0.05
pfset TimingInfo.DumpInterval    1000.0
pfset TimeStep.Type              Constant
pfset TimeStep.Value             10.

#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

pfset Geom.Porosity.GeomNames          "domain"

pfset Geom.domain.Porosity.Type          Constant
pfset Geom.domain.Porosity.Value         0.3

#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName domain

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type               VanGenuchten
pfset Phase.RelPerm.GeomNames          "domain"

pfset Geom.domain.RelPerm.Alpha         0.5
pfset Geom.domain.RelPerm.N             2.

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type              VanGenuchten
pfset Phase.Saturation.GeomNames         "domain"

pfset Geom.domain.Saturation.Alpha        0.50
pfset Geom.domain.Saturation.N            2.
pfset Geom.domain.Saturation.SRes         0.2
pfset Geom.domain.Saturation.SSat         1.0



#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                           ""

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names "constant rainrec"
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat             -1

# rainfall and recession time periods are defined here
# rain for 1 hour, recession for 2 hours

pfset Cycle.rainrec.Names                 "rain rec"
pfset Cycle.rainrec.rain.Length           1
pfset Cycle.rainrec.rec.Length            1000
pfset Cycle.rainrec.Repeat                -1

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   "land top river bottom"

#no flow boundaries for the land borders and the bottom
pfset Patch.land.BCPressure.Type		      FluxConst
pfset Patch.land.BCPressure.Cycle		      "constant"
pfset Patch.land.BCPressure.alltime.Value	      0.0

pfset Patch.bottom.BCPressure.Type		      FluxConst
pfset Patch.bottom.BCPressure.Cycle		      "constant"
pfset Patch.bottom.BCPressure.alltime.Value	      0.0

## overland flow boundary condition with rainfall then nothing
pfset Patch.top.BCPressure.Type		      FluxConst
pfset Patch.top.BCPressure.Cycle		      "rainrec"
pfset Patch.top.BCPressure.rain.Value	      0.0
pfset Patch.top.BCPressure.rec.Value	      -0.000001

pfset Patch.river.BCPressure.Type		      DirEquilRefPatch
#pfset Patch.river.BCPressure.Type		      FluxConst

pfset Patch.river.BCPressure.Cycle		      "constant"
pfset Patch.river.BCPressure.RefGeom			domain
pfset Patch.river.BCPressure.RefPatch			bottom
pfset Patch.river.BCPressure.alltime.Value	      501.0


#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------

pfset TopoSlopesX.Type "PFBFile"
pfset TopoSlopesX.GeomNames "domain"

pfset ComputationalGrid.NZ                1

pfset TopoSlopesX.FileName ../Slope_processing/SmallTest_Sec0_Upwind.slopex.pfb
pfdist ../Slope_processing/SmallTest_Sec0_Upwind.slopex.pfb

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------


#pfset TopoSlopesY.Type "Constant"
#pfset TopoSlopesY.GeomNames "domain"
#pfset TopoSlopesY.Geom.domain.Value 0.001
#pfset TopoSlopesY.Geom.domain.Value -0.01
#pfset TopoSlopesY.Geom.domain.Value 0.0

pfset TopoSlopesY.Type "PFBFile"
pfset TopoSlopesY.GeomNames "domain"
pfset TopoSlopesY.FileName ../Slope_processing/SmallTest_Sec0_Upwind.slopey.pfb
pfdist ../Slope_processing/SmallTest_Sec0_Upwind.slopey.pfb

pfset ComputationalGrid.NZ                2

#---------------------------------------------------------
# Mannings coefficient
#---------------------------------------------------------

pfset Mannings.Type "Constant"
pfset Mannings.GeomNames "domain"
pfset Mannings.Geom.domain.Value 2.e-6

#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------

pfset PhaseSources.water.Type                         Constant
pfset PhaseSources.water.GeomNames                    domain
pfset PhaseSources.water.Geom.domain.Value        0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------

pfset KnownSolution                                    NoKnownSolution


#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------

pfset Solver                                             Richards
pfset Solver.MaxIter                                     25000

pfset Solver.Nonlinear.MaxIter                           500
pfset Solver.Nonlinear.ResidualTol                       1e-6
#pfset Solver.Nonlinear.ResidualTol                       1e-7
pfset Solver.TerrainFollowingGrid                        True
pfset Solver.TerrainFollowingGrid.SlopeUpwindFormulation   Upwind

pfset Solver.Nonlinear.EtaChoice                         EtaConstant

pfset Solver.Nonlinear.EtaValue                          0.01
#pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-13
pfset Solver.Nonlinear.StepTol				 1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      100
pfset Solver.Linear.MaxRestarts                           5

pfset Solver.Linear.Preconditioner                       PFMGOctree
#pfset Solver.Linear.Preconditioner                       PFMG
#pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian

pfset Solver.PrintSubsurf				True
pfset  Solver.Drop                                      1E-30
pfset Solver.AbsTol                                     1E-9

pfset Solver.WriteSiloSubsurfData         False
pfset Solver.WriteSiloPressure            False
pfset Solver.WriteSiloSlopes              False

pfset Solver.WriteSiloSaturation          False
pfset Solver.WriteSiloConcentration       False

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
pfset ICPressure.Type                                   HydroStaticPatch
pfset ICPressure.GeomNames                              domain
pfset Geom.domain.ICPressure.Value                      250.0

pfset Geom.domain.ICPressure.RefGeom                    domain
pfset Geom.domain.ICPressure.RefPatch                   bottom

#-----------------------------------------------------------------------------
# Run and Unload the ParFlow output files
#-----------------------------------------------------------------------------
set runname "SmallTest_River"
pfrun $runname
pfundist $runname
