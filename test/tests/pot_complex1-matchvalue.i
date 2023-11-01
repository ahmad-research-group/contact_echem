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
  [./air]
   type = SubdomainBoundingBoxGenerator
   block_id = 1
   input = SE
   bottom_left = '0 5 0'
   top_right = '5 100 0'
  [../]
  [./interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = air
    primary_block = '0'
    paired_block = '1'
    new_boundary = 'interface'
  [../]
  [./boundaries]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
    boundaries = 'left top'
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
  [./uair_re]
    order = FIRST
    family = LAGRANGE
    block = 1
  [../]
  [./uair_im]
    order = FIRST
    family = LAGRANGE
    block = 1
  [../]
[]

[AuxVariables]
  [./use]
    order = FIRST
    family = MONOMIAL
    block = 0
  [../]
  [./uair]
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
  [./diffairu]
    type = ADMatDiffusion
    variable = uair_re
    diffusivity = 'omegaeps'
    block = 1 
  [../]
  [./diffairv]
    type = ADMatDiffusion
    variable = uair_im
    diffusivity = 'omegaeps'
    block = 1 
  [../]
[]

[InterfaceKernels]
  [./contactusere] 
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair_im
    boundary = interface
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
  [../]
  [./contactuseim]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair_re
    boundary = interface
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
    variable = uair
    x = uair_re
    y = uair_im
  [../]
  [./vgrad_uair_x]
    type = VariableGradientComponent
    variable = grad_uair_re_x
    component = x
    gradient_variable = uair_re
  [../]
  [./vgrad_uair_y]
    type = VariableGradientComponent
    variable = grad_uair_re_y
    component = y
    gradient_variable = uair_re
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
    gradient_variable = uair_im
  [../]
  [./vgrad_uair_imy]
    type = VariableGradientComponent
    variable = grad_uair_im_y
    component = y
    gradient_variable = uair_im
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
  [./air]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values =	'0. 0.00477'
  block = 1
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
    boundary = 'bottom top_to_0' 
    value = 0
  [../]
  [./noflux_seim]
    type = NeumannBC
    variable = use_im
    boundary = 'bottom top_to_0' 
    value = 0
  [../]
  [./noflux_airre]
    type = NeumannBC
    variable = uair_re
    boundary = 'top_to_1'
    value = 0
  [../]
  [./nofluxv_airim]
    type = NeumannBC
    variable = uair_im
    boundary = 'top_to_1'
    value = 0
  [../]
#left electrode - fix potential
  [./electrode_left_airre]
    type = DirichletBC
    variable = uair_re
    boundary = 'left_to_1' 
    value = 0
  [../]
  [./electrode_left_airim]
    type = DirichletBC
    variable = uair_im
    boundary = 'left_to_1' # This must match a named boundary in the mesh file
    value = 0
  [../]
  [./interface_match_re]
   type = MatchedValueBC
   variable = uair_re
   boundary = 'interface'
   v = use_re
  [../]
  [./interface_match_im]
   type = MatchedValueBC
   variable = uair_im
   boundary = 'interface'
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
