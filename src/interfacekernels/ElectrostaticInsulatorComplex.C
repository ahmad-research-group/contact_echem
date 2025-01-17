//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectrostaticInsulatorComplex.h"

registerMooseObject("contact_echemApp", ElectrostaticInsulatorComplex);

InputParameters
ElectrostaticInsulatorComplex::validParams()
{
  InputParameters params = ADInterfaceKernel::validParams();
  params.addRequiredParam<Real>("omega", "value of ac frequency");
  params.addParam<MaterialPropertyName>(
      "conductivity", "Conductivity on the primary block.");
  params.addParam<MaterialPropertyName>(
      "primary_permittivity", "Permittivity on the primary block.");
  params.addParam<MaterialPropertyName>(
      "secondary_permittivity", "Permittivity on the secondary block.");
  params.addCoupledVar("pot1im", "im part of the potential");
  params.addClassDescription(
      "Interface condition that describes the current continuity and contact conductance across a "
      "boundary formed between two dissimilar materials (resulting in a potential discontinuity). "
      "Conductivity on each side of the boundary is defined via the material properties system.");
  return params;
}

ElectrostaticInsulatorComplex::ElectrostaticInsulatorComplex(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _omega(getParam<Real>("omega")),
    _sigma(getADMaterialProperty<Real>("conductivity")),
    _eps(getADMaterialProperty<Real>("primary_permittivity")),
    _eps_neighbor(getNeighborADMaterialProperty<Real>("secondary_permittivity")),
    _grad_pot1im(adCoupledGradient("pot1im"))
{
}

ADReal
ElectrostaticInsulatorComplex::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0.0;

  switch (type)
  {
    case Moose::Element:
      r = -_test[_i][_qp] * _omega * ( _eps[_qp] * _grad_pot1im[_qp] - _eps_neighbor[_qp] * _grad_neighbor_value[_qp] )  * _normals[_qp];
      // var: phi1r, neighbor var: phi2i, kernel: - \nabla dot sigma \nabla phi1_r
      break;

    case Moose::Neighbor:
      r = -_test_neighbor[_i][_qp] * ( _sigma[_qp] * _grad_u[_qp] - _omega * _eps[_qp] * _grad_pot1im[_qp] ) * _normals[_qp];
      // kernel: -\nabla omega eps2 \nabla \phi2_i, minus sign due to normal direction opposite needed in the residual
      break;
  }

  return r;
}
