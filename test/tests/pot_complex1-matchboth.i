#Dir bc on left of both, potential continuity
[GlobalParams]
  omega = 10.0
[]

[Mesh]
  [./SE]
   type = GeneratedMeshGenerator
   dim = 2
   xmax = 100
   ymax = 100
   nx = 400
   ny = 400
   show_info = true
  [../]
  [./air1]
   type = SubdomainBoundingBoxGenerator
   block_id = 1
   input = SE
   bottom_left = '0 55 0'
   top_right = '5 100 0'
  [../]
  [./interface1]
    type = SideSetsBetweenSubdomainsGenerator
    input = air1
    primary_block = '0'
    paired_block = '1'
    new_boundary = 'interface1'
  [../]
  [./boundaries1]
    input = interface1
    type = BreakBoundaryOnSubdomainGenerator
    boundaries = 'left top'
  [../]
  [./air2]
   type = SubdomainBoundingBoxGenerator
   block_id = 2
   input = boundaries1
   bottom_left = '0 0 0'
   top_right = '5 45 0'
  [../]
  [./interface2]
    type = SideSetsBetweenSubdomainsGenerator
    input = air2
    primary_block = '0'
    paired_block = '2'
    new_boundary = 'interface2'
  [../]
  [./boundaries2]
    input = interface2
    type = BreakBoundaryOnSubdomainGenerator
    boundaries = 'left bottom'
  [../]
[]

# complex potential
[Variables]
  [./use_re]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./use_im]
    order = FIRST
    family = LAGRANGE
    block = 0
  [../]
  [./uair1_re]
    order = FIRST
    family = LAGRANGE
    block = 1
  [../]
  [./uair1_im]
    order = FIRST
    family = LAGRANGE
    block = 1
  [../]
    [./uair2_re]
    order = FIRST
    family = LAGRANGE
    block = 2
  [../]
  [./uair2_im]
    order = FIRST
    family = LAGRANGE
    block = 2
  [../]
[]

[AuxVariables]
  [./use]
    order = FIRST
    family = MONOMIAL
    block = 0
  [../]
  [./uair1]
    order = FIRST
    family = MONOMIAL
    block = 1
  [../]
  [./grad_uair_re_x]
   order = FIRST
  family = MONOMIAL
    block = 1
  [../]
  [./grad_uair_re_y]
   order = FIRST
  family = MONOMIAL
    block = 1
  [../]
    [./grad_use_re_x]
   order = FIRST
  family = MONOMIAL
    block = 0
  [../]
  [./grad_use_re_y]
    order = FIRST
    family = MONOMIAL
    block = 0
  [../]
  [./grad_uair_im_x]
   order = FIRST
  family = MONOMIAL
    block = 1
  [../]
  [./grad_uair_im_y]
   order = FIRST
  family = MONOMIAL
    block = 1
  [../]
    [./grad_use_im_x]
   order = FIRST
  family = MONOMIAL
    block = 0
  [../]
  [./grad_use_im_y]
   order = FIRST
  family = MONOMIAL
    block = 0
  [../]
[]

  
[Kernels]
  [./diffseu]
    type = ADMatDiffusion
    variable = use_re
    diffusivity = 'sigma'
    block = 0
  [../]
  [./diffsev]
    type = ADMatDiffusion
    variable = use_im
    diffusivity = 'sigma'
    block = 0
  [../]
  [./diffairu1]
    type = ADMatDiffusion
    variable = uair1_re
    diffusivity = 'omegaeps'
    block = 1 
  [../]
  [./diffairv1]
    type = ADMatDiffusion
    variable = uair1_im
    diffusivity = 'omegaeps'
    block = 1 
  [../]
    [./diffairu2]
    type = ADMatDiffusion
    variable = uair2_re
    diffusivity = 'omegaeps'
    block = 2
  [../]
  [./diffairv2]
    type = ADMatDiffusion
    variable = uair2_im
    diffusivity = 'omegaeps'
    block = 2
  [../]
[]

[InterfaceKernels]
  [./contactusere1] 
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair1_im
    boundary = interface1
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
  [../]
  [./contactuseim1]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair1_re
    boundary = interface1
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1re = use_re
  [../]
    [./contactusere2]
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair2_im
    boundary = interface2
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
  [../]
  [./contactuseim2]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair2_re
    boundary = interface2
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1re = use_re
  [../]
[]

[AuxKernels]
  [./use_magn]
    type = VectorMagnitudeAux
    variable = use
    x = use_re
    y = use_im
  [../]
  [./uair_magn]
    type = VectorMagnitudeAux
    variable = uair1
    x = uair1_re
    y = uair1_im
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
  prop_values = '1.0 0.016'
  block = 0
  outputs = exodus
  [../]
  [./air1]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values =	'0. 0.00477'
  block = 1
  outputs = exodus
  [../]
  [./air2]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values = '0. 0.00477'
  block = 2
  outputs = exodus
  [../]
  [./omegaeps]
    type = ADParsedMaterial
    property_name = omegaeps
    material_property_names = 'eps'
    constant_names = 'omega'
    constant_expressions = '10.0'
    expression = 'omega * eps'
    outputs = exodus
  [../]
  [./lhs1x]
    type = ADParsedMaterial
    property_name = lhs1x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'use_re use_im grad_use_re_x grad_use_im_x'
    expression = 'sigma * grad_use_re_x - omegaeps * grad_use_im_x'
    block = 0
    outputs = exodus
  [../]
  [./rhs1x]
    type = ADParsedMaterial
    property_name = rhs1x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_x grad_uair_im_x'
    expression = '-omegaeps * grad_uair_im_x'
    block = 1
    outputs = exodus
  [../]
  [./lhs2x]
    type = ADParsedMaterial
    property_name = lhs2x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_x grad_use_im_x'
    expression = 'omegaeps * grad_use_re_x + sigma * grad_use_im_x'
    block = 0
    outputs = exodus
  [../]
  [./rhs2x]
    type = ADParsedMaterial
    property_name = rhs2x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_x'
    expression = 'omegaeps * grad_uair_re_x'
    block = 1
    outputs = exodus
  [../]
    [./lhs1y]
    type = ADParsedMaterial
    property_name = lhs1y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_y grad_use_im_y'
    expression = 'sigma * grad_use_re_y - omegaeps * grad_use_im_y'
    block = 0
    outputs = exodus
  [../]
  [./rhs1y]
    type = ADParsedMaterial
    property_name = rhs1y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_im_y'
    expression = '-omegaeps * grad_uair_im_y'
    block = 1
    outputs = exodus
  [../]
    [./lhs2y]
    type = ADParsedMaterial
    property_name = lhs2y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_y grad_use_im_y'
    expression = 'omegaeps * grad_use_re_y + sigma * grad_use_im_y'
    block = 0
    outputs = exodus
  [../]
  [./rhs2y]
    type = ADParsedMaterial
    property_name = rhs2y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_y'
    expression = 'omegaeps * grad_uair_re_y'
    block = 1
    outputs = exodus
  [../]
[]
  
[BCs]
#  active = 'nofluxu_se nofluxu_air electrode_leftu_air electrode_leftu electrode_rightu'
  [./noflux_sere] # arbitrary user-chosen name
    type = NeumannBC
    variable = use_re
    boundary = 'bottom_to_0 top_to_0' 
    value = 0
  [../]
  [./noflux_seim]
    type = NeumannBC
    variable = use_im
    boundary = 'bottom_to_0 top_to_0' 
    value = 0
  [../]
  [./noflux_air1re]
    type = NeumannBC
    variable = uair1_re
    boundary = 'top_to_1'
    value = 0
  [../]
  [./nofluxv_air1im]
    type = NeumannBC
    variable = uair1_im
    boundary = 'top_to_1'
    value = 0
  [../]
  [./noflux_air2re]
    type = NeumannBC
    variable = uair2_re
    boundary = 'bottom_to_2'
    value = 0
  [../]
  [./nofluxv_air2im]
    type = NeumannBC
    variable = uair2_im
    boundary = 'bottom_to_2'
    value = 0
  [../]
#left electrode - fix potential
  [./electrode_left_air1re]
    type = DirichletBC
    variable = uair1_re
    boundary = 'left_to_1' 
    value = 0
  [../]
  [./electrode_left_air1im]
    type = DirichletBC
    variable = uair1_im
    boundary = 'left_to_1' # This must match a named boundary in the mesh file
    value = 0
  [../]
    [./electrode_left_air2re]
    type = DirichletBC
    variable = uair2_re
    boundary = 'left_to_2'
    value = 0
  [../]
  [./electrode_left_air2im]
    type = DirichletBC
    variable = uair2_im
    boundary = 'left_to_2' # This must match a named boundary in the mesh file
    value = 0
  [../]
  #match potentials
  [./interface1_match_re]
   type = MatchedValueBC
   variable = uair1_re
   boundary = 'interface1'
   v = use_re
  [../]
  [./interface1_match_im]
   type = MatchedValueBC
   variable = uair1_im
   boundary = 'interface1'
   v = use_im
  [../]
  [./interface2_match_re]
   type = MatchedValueBC
   variable = uair2_re
   boundary = 'interface2'
   v = use_re
  [../]
  [./interface2_match_im]
   type = MatchedValueBC
   variable = uair2_im
   boundary = 'interface2'
   v = use_im
  [../]
  [./electrode_left_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'left_to_0' # This must match a named boundary in the mesh file
    value = 0
  [../]
  [./electrode_left_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'left_to_0'
    value = 0
  [../]
  [./electrode_right_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'right'
    value = 1.0
  [../]
  [./electrode_right_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'right'
    value = 0.0
  [../]
[]

[Executioner]
  automatic_scaling = true
  type = Steady
  verbose = True
  solve_type = 'Newton'
  l_max_its = 50
  l_tol = 1e-6
  nl_max_its = 50
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-12
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly      lu          4'
[]


[Postprocessors]
  [./current_re1]
    type = ADSideDiffusiveFluxIntegral
    variable = use_re
    boundary = right
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_re2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = right
    diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
  [./current_im1]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = right
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_im2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_re
    boundary = right
    diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
[]
  
[Outputs]
  execute_on = 'FINAL'
  exodus = true
[]
