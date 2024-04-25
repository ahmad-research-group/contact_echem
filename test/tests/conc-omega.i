#Dir bc on left of both, potential continuity
[GlobalParams]
  omega = OMEGAVALUE
[]

[Mesh]
  [./fmg]
    type = FileMeshGenerator
    file = './grooved-hse_3.01-depth_5.01-period_20.00-nreps_5.msh'
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
  [./rhosigmabyeps_term]
    type = MaskedBodyForce
    variable = use_re
    value = 1.0
    mask = rhosigmabyeps_linear
  [../]
[]

[InterfaceKernels]
  [./contactusere1] 
    type = ElectrostaticInsulatorComplex
    variable = use_re
    neighbor_var = uair1_im
    boundary = interface
    conductivity = sigma
    primary_permittivity = 'eps'
    secondary_permittivity = 'eps'
    pot1im = use_im
  [../]
  [./contactuseim1]
    type = ElectrostaticInsulatorComplexIm
    variable = use_im
    neighbor_var = uair1_re
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
    [./consts]
    type = GenericConstantMaterial
    prop_names = 'N kT e dfepos0 dfeneg0 alpha'
    prop_values = '5.98412e28 4.142e-21 1.602e-19 1.0e-19 1.0e-19 0.1'
#    block = 'se'
  [../]
  [./se]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values = '0.01 8.85e-11'
  block = 'se'
  outputs = exodus
  [../]
  [./air1]
  type = ADGenericConstantMaterial
  prop_names = 'sigma eps'
  prop_values =	'0. 8.85e-12'
  block = 'air'
  outputs = exodus
  [../]
  [./omegaeps]
    type = ADParsedMaterial
    property_name = omegaeps
    material_property_names = 'eps'
    constant_names = 'omega'
    constant_expressions = OMEGAVALUE
    expression = 'omega * eps'
    outputs = exodus
  [../]
  [./cpos]
    type = DerivativeParsedMaterial
    property_name = 'cpos'
    coupled_variables = 'use_re'
    material_property_names = 'dfepos0 N kT e alpha'
    expression = 'N/( exp((dfepos0 + e * use_re)/kT) + 1/alpha)'
    derivative_order = 2
    outputs = exodus
    block  = 'se'
  [../]
  [./cneg]
    type = DerivativeParsedMaterial
    property_name = 'cneg'
    coupled_variables = 'use_re'
    material_property_names = 'dfeneg0 N kT e alpha'
    expression = 'N/ (exp((dfeneg0 - e * use_re)/kT) + 1/alpha)'
    derivative_order = 2
    outputs = exodus
    block = 'se'
  [../]
  [converter_to_regular_sigma]
    type = MaterialADConverter
    ad_props_in = 'sigma'
    reg_props_out = 'sigma_reg'
  []
  [converter_to_regular_eps]
    type = MaterialADConverter
    ad_props_in = 'eps'
    reg_props_out = 'eps_reg'
  []
  [./rhosigmabyeps]
    type = DerivativeParsedMaterial
    property_name = 'rhosigmabyeps'
    coupled_variables = 'use_re'
    material_property_names = 'cpos(use_re) cneg(use_re) e sigma_reg eps_reg'
    expression = 'e*( cpos - cneg ) * sigma_reg/eps_reg'
    derivative_order = 2
    outputs = exodus
    block = 'se'
  [../]
  [./rhosigmabyeps_linear]
    type = DerivativeParsedMaterial
    property_name = 'rhosigmabyeps_linear'
    coupled_variables = 'use_re'
    material_property_names = 'e sigma_reg eps_reg dfepos0 kT N'
    expression = '2 * N * exp(-dfepos0/kT) * e / kT * use_re * sigma_reg / eps_reg'
    derivative_order = 2
    outputs = exodus
    block = 'se'
  [../]
  [./lhs1x]
    type = ADParsedMaterial
    property_name = lhs1x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'use_re use_im grad_use_re_x grad_use_im_x'
    expression = 'sigma * grad_use_re_x - omegaeps * grad_use_im_x'
    block = 'se'
    outputs = exodus
  [../]
  [./rhs1x]
    type = ADParsedMaterial
    property_name = rhs1x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_x grad_uair_im_x'
    expression = '-omegaeps * grad_uair_im_x'
    block = 'air'
    outputs = exodus
  [../]
  [./lhs2x]
    type = ADParsedMaterial
    property_name = lhs2x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_x grad_use_im_x'
    expression = 'omegaeps * grad_use_re_x + sigma * grad_use_im_x'
    block = 'se'
    outputs = exodus
  [../]
  [./rhs2x]
    type = ADParsedMaterial
    property_name = rhs2x
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_x'
    expression = 'omegaeps * grad_uair_re_x'
    block = 'air'
    outputs = exodus
  [../]
    [./lhs1y]
    type = ADParsedMaterial
    property_name = lhs1y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_y grad_use_im_y'
    expression = 'sigma * grad_use_re_y - omegaeps * grad_use_im_y'
    block = 'se'
    outputs = exodus
  [../]
  [./rhs1y]
    type = ADParsedMaterial
    property_name = rhs1y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_im_y'
    expression = '-omegaeps * grad_uair_im_y'
    block = 'air'
    outputs = exodus
  [../]
    [./lhs2y]
    type = ADParsedMaterial
    property_name = lhs2y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_use_re_y grad_use_im_y'
    expression = 'omegaeps * grad_use_re_y + sigma * grad_use_im_y'
    block = 'se'
    outputs = exodus
  [../]
  [./rhs2y]
    type = ADParsedMaterial
    property_name = rhs2y
    material_property_names = 'sigma omegaeps'
    coupled_variables = 'grad_uair_re_y'
    expression = 'omegaeps * grad_uair_re_y'
    block = 'air'
    outputs = exodus
  [../]
[]
  
[BCs]
#  active = 'nofluxu_se nofluxu_air electrode_leftu_air electrode_leftu electrode_rightu'
  [./noflux_sere] # arbitrary user-chosen name
    type = NeumannBC
    variable = use_re
    boundary = 'top_bottom_se' 
    value = 0
  [../]
  [./noflux_seim]
    type = NeumannBC
    variable = use_im
    boundary = 'top_bottom_se'
    value = 0
  [../]
#left electrode - fix potential
  [./electrode_left_air1re]
    type = DirichletBC
    variable = uair1_re
    boundary = 'left_air' 
    value = -0.05
  [../]
  [./electrode_left_air1im]
    type = DirichletBC
    variable = uair1_im
    boundary = 'left_air' # This must match a named boundary in the mesh file
    value = 0
  [../]
  #match potentials
  [./interface1_match_re]
   type = MatchedValueBC
   variable = uair1_re
   boundary = 'interface'
   v = use_re
  [../]
  [./interface1_match_im]
   type = MatchedValueBC
   variable = uair1_im
   boundary = 'interface'
   v = use_im
  [../]
  [./electrode_left_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'left_se'
    value = -0.05
  [../]
  [./electrode_left_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'left_se'
    value = 0
  [../]
  [./electrode_right_sere]
    type = DirichletBC
    variable = use_re
    boundary = 'right_se'
    value = 0.05
  [../]
  [./electrode_right_seim]
    type = DirichletBC
    variable = use_im
    boundary = 'right_se'
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
    boundary = right_se
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_re2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = right_se
   diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
  [./current_im1]
    type = ADSideDiffusiveFluxIntegral
    variable = use_im
    boundary = right_se
    diffusivity = 'sigma'
    execute_on = 'FINAL'
  [../]
    [./current_im2]
    type = ADSideDiffusiveFluxIntegral
    variable = use_re
    boundary = right_se
    diffusivity = 'omegaeps'
    execute_on = 'FINAL'
  [../]
[]
  
[Outputs]
  execute_on = 'FINAL'
  exodus = true
[]
