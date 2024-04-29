//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectrostaticInsulatorComplexIm.h"

registerMooseObject("contact_echemApp", ElectrostaticInsulatorComplexIm);

InputParameters
ElectrostaticInsulatorComplexIm::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<Real>("omega", "value of ac frequency");
  params.addRequiredParam<MaterialPropertyName>(
      "conductivity", "Conductivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "conductivity_neighbor", "Conductivity on the neighbor block.");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_permittivity", "Permittivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_permittivity", "Permittivity on the secondary block.");
  params.addRequiredCoupledVar("pot1re", "re part of the potential for 1");
  params.addRequiredCoupledVar("pot2im", "re part of the potential for 2");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_diffusivity", "Diffusivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_diffusivity", "Diffusivity on the secondary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_conc", "Concentration on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_conc", "Concentration on the secondary block.");
  params.addClassDescription(
      "Interface condition that describes the current continuity and contact conductance across a "
      "boundary formed between two dissimilar materials (resulting in a potential discontinuity). "
      "Conductivity on each side of the boundary is defined via the material properties system.");
  return params;
  // kernel var = phi1i, neighbor var = phi2r
}

ElectrostaticInsulatorComplexIm::ElectrostaticInsulatorComplexIm(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _omega(getParam<Real>("omega")),
    _sigma(getADMaterialProperty<Real>("conductivity")),
    _sigma_neighbor(getNeighborADMaterialProperty<Real>("conductivity_neighbor")),
    _eps(getADMaterialProperty<Real>("primary_permittivity")),
    _eps_neighbor(getNeighborADMaterialProperty<Real>("secondary_permittivity")),
    _D(getADMaterialProperty<Real>("primary_diffusivity")),
    _D_neighbor(getNeighborADMaterialProperty<Real>("secondary_diffusivity")),
    _grad_pot2im(adCoupledNeighborGradient("pot2im")),
    _grad_pot1re(adCoupledGradient("pot1re")),
    _dcpos_dphi(getADMaterialProperty<Real>("primary_conc")),
    _dcpos_neighbor_dphi(getNeighborADMaterialProperty<Real>("secondary_conc"))
{
}

ADReal
ElectrostaticInsulatorComplexIm::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0.0;

  switch (type)
  {
    case Moose::Element:
      r = -_test[_i][_qp] * ( _omega * ( _eps_neighbor[_qp] * _grad_neighbor_value[_qp] 
      - _eps[_qp] * _grad_pot1re[_qp] ) + _sigma_neighbor[_qp] * _grad_pot2im[_qp] 
      - _dcpos_neighbor_dphi[_qp] * _grad_neighbor_value[_qp] 
      + _dcpos_dphi[_qp] * _grad_pot1re[_qp] ) * _normals[_qp];
      // var = phi1i, neighbor var = phi2r; kernel: - \nabla sigma \nabla phi1_i
      // dcposdphi is -D * dcpos_dphi
      break;

    case Moose::Neighbor:
      r = _test_neighbor[_i][_qp] * ( _omega * _eps[_qp] * _grad_pot1re[_qp] 
      + _sigma[_qp] * _grad_u[_qp] - _dcpos_dphi[_qp] * _grad_pot1re[_qp] 
      + _dcpos_neighbor_dphi[_qp] * _grad_neighbor_value[_qp] ) * _normals[_qp];
      // kernel: - \nabla omega eps2 \nabla phi2r
      break;
  }

  return r;
}
