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
  params.addParam<MaterialPropertyName>(
      "conductivity", "Conductivity on the primary block.");
  params.addParam<MaterialPropertyName>(
      "primary_permittivity", "Permittivity on the primary block.");
  params.addParam<MaterialPropertyName>(
      "secondary_permittivity", "Permittivity on the secondary block.");
  params.addCoupledVar("pot1re", "re part of the potential");
  //  params.addCoupledVar("v2", "im part of the potential");
  //#  params.addRequiredCoupledVar("", "chemical potential");
  //#  params.addParam<Real>("user_electrical_contact_conductance", "User-supplied electrical contact conductance coefficient.");
  //#  params.addParam<FunctionName>("mechanical_pressure", 0.0, "Mechanical pressure uniformly applied at the contact surface area ", "(Pressure = Force / Surface Area).");
  params.addClassDescription(
      "Interface condition that describes the current continuity and contact conductance across a "
      "boundary formed between two dissimilar materials (resulting in a potential discontinuity). "
      "Conductivity on each side of the boundary is defined via the material properties system.");
  return params;
}

ElectrostaticInsulatorComplexIm::ElectrostaticInsulatorComplexIm(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _omega(getParam<Real>("omega")),
    _sigma(getADMaterialProperty<Real>("conductivity")),
    _eps(getADMaterialProperty<Real>("primary_permittivity")),
    _eps_neighbor(getNeighborADMaterialProperty<Real>("secondary_permittivity")),
    _grad_pot1re(adCoupledGradient("pot1re"))
{
}

ADReal
ElectrostaticInsulatorComplexIm::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0.0;

  switch (type)
  {
    case Moose::Element:
      r = -_test[_i][_qp] * _omega * ( _eps_neighbor[_qp] * _grad_neighbor_value[_qp] - _eps[_qp] * _grad_pot1re[_qp] )  * _normals[_qp];
      // var = phi1i, neighbor var = phi2r; kernel: - \nabla sigma \nabla phi1_i
      break;

    case Moose::Neighbor:
      r = _test_neighbor[_i][_qp] * ( _omega * _eps[_qp] * _grad_pot1re[_qp] + _sigma[_qp] * _grad_u[_qp] ) * _normals[_qp];
      // kernel: - \nabla omega eps2 \nabla phi2r
      break;
  }

  return r;
}
