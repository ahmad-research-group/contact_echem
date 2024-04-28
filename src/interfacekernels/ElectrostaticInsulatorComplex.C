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
  params.addRequiredParam<MaterialPropertyName>(
      "conductivity", "Conductivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "conductivity_neighbor", "Conductivity on the neighbor block.");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_permittivity", "Permittivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_permittivity", "Permittivity on the secondary block.");
  params.addRequiredCoupledVar("pot1im", "im part of the potential");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_diffusivity", "Diffusivity on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_diffusivity", "Diffusivity on the secondary block.");
  params.addRequiredCoupledVar("pot2re", "re part of the potential of neigbor");
  params.addRequiredParam<MaterialPropertyName>(
      "primary_conc", "Concentration on the primary block.");
  params.addRequiredParam<MaterialPropertyName>(
      "secondary_conc", "Concentration on the secondary block.");
  params.addClassDescription(
      "Interface condition that describes the current continuity and contact conductance across a "
      "boundary formed between two dissimilar materials (resulting in a potential discontinuity). "
      "Conductivity on each side of the boundary is defined via the material properties system.");
  return params;
  // kernel var is pot1re and neighbor is pot2im
  // kernel: -\nabla omega eps2 \nabla \phi2_i
}

ElectrostaticInsulatorComplex::ElectrostaticInsulatorComplex(const InputParameters & parameters)
  : ADInterfaceKernel(parameters),
    _omega(getParam<Real>("omega")),
    _sigma(getADMaterialProperty<Real>("conductivity")),
    _sigma_neighbor(getNeighborADMaterialProperty<Real>("conductivity_neighbor")),
    _eps(getADMaterialProperty<Real>("primary_permittivity")),
    _eps_neighbor(getNeighborADMaterialProperty<Real>("secondary_permittivity")),
    _grad_pot1im(adCoupledGradient("pot1im")),
    _D(getADMaterialProperty<Real>("primary_diffusivity")),
    _D_neighbor(getNeighborADMaterialProperty<Real>("secondary_diffusivity")),
    _pot2re(adCoupledNeighborValue("pot2re")),
    _grad_pot2re(adCoupledNeighborGradient("pot2re")),
    _pot2re_name(coupledName("pot2re")),
    _cpos(getADMaterialProperty<Real>("primary_conc")),
    _cpos_name(getParam<MaterialPropertyName>("primary conc")),
    _dcpos_dphi(getADMaterialProperty<Real>(derivativePropertyNameFirst(_cpos_name, _var.name()))),
    //    _cpos(getADMaterialPropertyName<Real>("primary_conc")),
    //    _cpos_neighbor_name(getNeighborADMaterialPropertyName<Real>("secondary_conc")),
    //    _pot1re_name(getVar("u", 0)->name()),
    //  _pot1re_name(getVar("u",0)->name()),
    //        _pot2re_name(getVar("pot2re", 0)->name()),
    _cpos_neighbor(getNeighborADMaterialProperty<Real>("secondary_conc")),
    _cpos_neighbor_name(getParam<MaterialPropertyName>("secondary conc")),
    _dcpos_neighbor_dphi(getNeighborADMaterialProperty<Real>(derivativePropertyNameFirst(_cpos_neighbor_name, _pot2re_name)))
    //    _dcpos_dphi(getMaterialPropertyDerivative<Real>(_cpos_name, _var.name())),
    //  _dcpos_dphi(getADMaterialProperty<Real>(derivativePropertyNameFirst(_name_L, _var.name())),
    //    _dcpos_neighbor_dphi(getMaterialPropertyDerivative<Real>("primary_conc", _pot2re_name))
    //    _dcpos_dphi(getADMaterialProperty<Real>(this->derivativePropertyNameFirst(_cpos_name, _var.name()))),
    //    _dcpos_neighbor_dphi(getNeighborADMaterialProperty<Real>(derivativePropertyNameFirst(_cpos_neighbor_name, _var.name())))
{
}

ADReal
ElectrostaticInsulatorComplex::computeQpResidual(Moose::DGResidualType type)
{
  ADReal r = 0.0;

  switch (type)
  {
    case Moose::Element:
      r = -_test[_i][_qp] * ( _omega * ( _eps[_qp] * _grad_pot1im[_qp] - _eps_neighbor[_qp] * _grad_neighbor_value[_qp] ) + _sigma_neighbor[_qp] * _grad_pot2re[_qp] + _D_neighbor[_qp] * _dcpos_neighbor_dphi[_qp] * _grad_pot2re[_qp] - _D[_qp] * _dcpos_dphi[_qp] * _grad_u[_qp] ) * _normals[_qp];
      // _omega * ( _eps[_qp] * _grad_pot1im[_qp] - _eps_neighbor[_qp] * _grad_neighbor_value[_qp] )  * _normals[_qp];
      // var: phi1r, neighbor var: phi2i, kernel: - \nabla dot sigma \nabla phi1_r
      // negative sign comes from integration by parts
      break;

    case Moose::Neighbor:
      r = -_test_neighbor[_i][_qp] * ( _sigma[_qp] * _grad_u[_qp] - _omega * _eps[_qp] * _grad_pot1im[_qp] -_sigma_neighbor[_qp] * _grad_pot2re[_qp] - _D_neighbor[_qp] * _dcpos_neighbor_dphi[_qp] * _grad_pot2re[_qp] - _D[_qp] * _dcpos_dphi[_qp] * _grad_u[_qp] ) * _normals[_qp];
      // minus sign due to normal direction opposite needed in the residual
      break;
  }

  return r;
}
