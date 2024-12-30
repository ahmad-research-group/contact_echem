#Dir bc on left of both, potential continuity
omega = OMEGAVALUE


[Mesh]
  [./fmg]
    type = FileMeshGenerator
    file = './only_by_gmsh_1_hole.msh'  #put the correct mesh file name here
  []
  [./rename]
  type = RenameBlockGenerator
  input = fmg
  old_block = 'paper'
  new_block = 'air'
  []
  [./rename1]
  type = RenameBlockGenerator
  input = rename
  old_block = 'pellet'
  new_block = 'se'
  []
[]

# complex potential
[Variables]
  [./use_re]
    order = FIRST
    family = LAGRANGE
    block = 'se'
  [../]
  [./use_im]
    order = FIRST
    family = LAGRANGE
    block = 'se'
  [../]
  [./uair1_re]
    order = FIRST
    family = LAGRANGE
    block = 'air'
  [../]
  [./uair1_im]
    order = FIRST
    family = LAGRANGE
    block = 'air'
  [../]
[]

[AuxVariables]
  [./use]
    order = FIRST
    family = MONOMIAL
    block = 'se'
  [../]
  [./uair1]
    order = FIRST
    family = MONOMIAL
    block = 'air'
  [../]
  [./grad_uair_re_x]
   order = FIRST
  family = MONOMIAL
    block = 'air'
  [../]
  [./grad_uair_re_y]
   order = FIRST
  family = MONOMIAL
    block = 'air'
  [../]
    [./grad_use_re_x]
   order = FIRST
  family = MONOMIAL
    block = 'se'
  [../]
  [./grad_use_re_y]
    order = FIRST
    family = MONOMIAL
    block = 'se'
  [../]
  [./grad_uair_im_x]
   order = FIRST
  family = MONOMIAL
    block = 'air'
  [../]
  [./grad_uair_im_y]
   order = FIRST
  family = MONOMIAL
    block = 'air'
  [../]
    [./grad_use_im_x]
   order = FIRST
  family = MONOMIAL
    block = 'se'
  [../]
  [./grad_use_im_y]
   order = FIRST
  family = MONOMIAL
    block = 'se'
  [../]
[]

  
[Kernels]
  [./diffseu]
    type = ADMatDiffusion
    variable = use_re
    diffusivity = 'sigma'
    block = 'se'
  [../]
  [./diffsev]
    type = ADMatDiffusion
    variable = use_im
    diffusivity = 'sigma'
    block = 'se'
  [../]
  [./diffairu1]
    type = ADMatDiffusion
    variable = uair1_re
    diffusivity = 'omegaeps'
    block = 'air'
  [../]
  [./diffairv1]
    type = ADMatDiffusion
    variable = uair1_im
    diffusivity = 'omegaeps'
    block = 'air'
  [../]
[]

[InterfaceKernels]
  [./contactusere1] 
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair1_im
    boundary = int_pel_pap_side
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
    omega = ${omega}
  [../]
  [./contactuseim1]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair1_re
    boundary = int_pel_pap_side
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1re = use_re
  omega = ${omega}
  [../]
    [./contactusere1_top]
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair1_im
    boundary = int_pel_pap_top
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
    omega = ${omega}
  [../]
  [./contactuseim1_top]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair1_re
    boundary = int_pel_pap_top
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1re = use_re
    omega = ${omega}
  [../]

[]

[AuxKernels]
  [./use_magn]
    type = VectorMagnitudeAux
    variable = use
    x = use_re
    y = use_im
    z = 0
  [../]
  [./uair_magn]
    type = VectorMagnitudeAux
    variable = uair1
    x = uair1_re
    y = uair1_im
    z = 0
  [../]
  [./vgrad_uair_x]
    type = VariableGradientComponent
    variable = grad_uair_re_x
    component = x
    gradient_variable = uair1_re
  [../]
  [./vgrad_uair_y]
    type = VariableGradientComponent
    variable = grad_uair_re_y
    component = y
    gradient_variable = uair1_re
  [../]
    [./vgrad_use_x]
    type = VariableGradientComponent
    variable = grad_use_re_x
    component = x
    gradient_variable = use_re
  [../]
  [./vgrad_use_y]
    type = VariableGradientComponent
    variable = grad_use_re_y
    component = y
    gradient_variable = use_re
  [../]
  [./vgrad_uair_imx]
    type = VariableGradientComponent
    variable = grad_uair_im_x
    component = x
    gradient_variable = uair1_im
  [../]
  [./vgrad_uair_imy]
    type = VariableGradientComponent
    variable = grad_uair_im_y
    component = y
    gradient_variable = uair1_im
  [../]
    [./vgrad_use_imx]
    type = VariableGradientComponent
    variable = grad_use_im_x
    component = x
    gradient_variable = use_im
  [../]
  [./vgrad_use_imy]
    type = VariableGradientComponent
    variable = grad_use_im_y
    component = y
    gradient_variable = use_im
  [../]
[]
  
[Materials]
#  active = 'se air omegaeps'
  [./se]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values = '24800 4.427e-05'
  block = 'se'
  outputs = exodus
  [../]
  [./air1]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values =	'0.0 1.23956e-05'
  block = 'air'
  outputs = exodus
  [../]
  [./omegaeps]
    type = ADParsedMaterial
    property_name = omegaeps
    material_property_names = 'eps'
    constant_names = 'omega'
    constant_expressions = ${omega}
    expression = 'omega * eps'
    outputs = exodus
  [../]
  # [./lhs1x]
  #   type = ADParsedMaterial
  #   property_name = lhs1x
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'use_re use_im grad_use_re_x grad_use_im_x'
  #   expression = 'sigma * grad_use_re_x - omegaeps * grad_use_im_x'
  #   block = 'se'
  #   outputs = exodus
  # [../]
  # [./rhs1x]
  #   type = ADParsedMaterial
  #   property_name = rhs1x
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_uair_re_x grad_uair_im_x'
  #   expression = '-omegaeps * grad_uair_im_x'
  #   block = 'air'
  #   outputs = exodus
  # [../]
  # [./lhs2x]
  #   type = ADParsedMaterial
  #   property_name = lhs2x
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_use_re_x grad_use_im_x'
  #   expression = 'omegaeps * grad_use_re_x + sigma * grad_use_im_x'
  #   block = 'se'
  #   outputs = exodus
  # [../]
  # [./rhs2x]
  #   type = ADParsedMaterial
  #   property_name = rhs2x
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_uair_re_x'
  #   expression = 'omegaeps * grad_uair_re_x'
  #   block = 'air'
  #   outputs = exodus
  # [../]
  #   [./lhs1y]
  #   type = ADParsedMaterial
  #   property_name = lhs1y
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_use_re_y grad_use_im_y'
  #   expression = 'sigma * grad_use_re_y - omegaeps * grad_use_im_y'
  #   block = 'se'
  #   outputs = exodus
  # [../]
  # [./rhs1y]
  #   type = ADParsedMaterial
  #   property_name = rhs1y
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_uair_im_y'
  #   expression = '-omegaeps * grad_uair_im_y'
  #   block = 'air'
  #   outputs = exodus
  # [../]
  #   [./lhs2y]
  #   type = ADParsedMaterial
  #   property_name = lhs2y
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_use_re_y grad_use_im_y'
  #   expression = 'omegaeps * grad_use_re_y + sigma * grad_use_im_y'
  #   block = 'se'
  #   outputs = exodus
  # [../]
  # [./rhs2y]
  #   type = ADParsedMaterial
  #   property_name = rhs2y
  #   material_property_names = 'sigma omegaeps'
  #   coupled_variables = 'grad_uair_re_y'
  #   expression = 'omegaeps * grad_uair_re_y'
  #   block = 'air'
  #   outputs = exodus
  # [../]
[]
  
[BCs]
#  active = 'nofluxu_se nofluxu_air electrode_leftu_air electrode_leftu electrode_rightu'
  [./noflux_sere] # arbitrary user-chosen name
    type = NeumannBC
    variable = use_re
    boundary = 'pellet_side'
    value = 0
  [../]
  [./noflux_seim]
    type = NeumannBC
    variable = use_im
    boundary = 'pellet_side'
    value = 0
  [../]
    [./noflux_airre] # arbitrary user-chosen name
    type = NeumannBC
    variable = uair1_re
    boundary = 'paper_side' 
    value = 0
  [../]
  [./noflux_airim]
    type = NeumannBC
    variable = uair1_im
    boundary = 'paper_side'
    value = 0
  [../]
#left electrode - fix potential
  [./electrode_left_air1re]
    type = DirichletBC
    variable = uair1_re
    boundary = 'paper_top' 
    value = 0
  [../]
  [./electrode_left_air1im]
    type = DirichletBC
    variable = uair1_im
    boundary = 'paper_top' # This must match a named boundary in the mesh file
    value = 0
  [../]
  #match potentials
  [./interface1_match_re_side]
   type = MatchedValueBC
   variable = uair1_re
   boundary = 'int_pel_pap_side'
   v = use_re
  [../]
  [./interface1_match_im_side]
   type = MatchedValueBC
   variable = uair1_im
   boundary = 'int_pel_pap_side'
   v = use_im
  [../]
  [./interface1_match_re_top]
   type = MatchedValueBC
   variable = uair1_re
   boundary = 'int_pel_pap_top'
   v = use_re
  [../]
  [./interface1_match_im_top]
   type = MatchedValueBC
   variable = uair1_im
   boundary = 'int_pel_pap_top'
   v = use_im
  [../]
  [./electrode_left_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'pellet_top'
    value = 0
  [../]
  [./electrode_left_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'pellet_top'
    value = 0
  [../]
  [./electrode_right_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'pellet_bottom'
    value = 1.0
  [../]
  [./electrode_right_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'pellet_bottom'
    value = 0.0
  [../]
[]

[Executioner]
  automatic_scaling = true
  type = Steady
  verbose = True
  solve_type = 'Newton'
  l_max_its = 50
  l_tol = 1e-8
  nl_max_its = 50
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-16
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly      lu          4'
[]


[Postprocessors]
  [./current_re1]
    type = ADSideDiffusiveFluxIntegral
    variable = use_re
    boundary = pellet_bottom
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_re2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = pellet_bottom
   diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
  [./current_im1]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = pellet_bottom
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_im2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_re
    boundary = pellet_bottom
    diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
[]
  
[Outputs]
  execute_on = 'FINAL'
  exodus = true
[]
