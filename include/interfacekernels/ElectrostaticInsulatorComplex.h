//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADInterfaceKernel.h"
#include "DerivativeMaterialPropertyNameInterface.h"
#include "Function.h"

/**
 *  This ADInterfaceKernel object calculates the electrostatic potential value
 *  and gradient relationship as a result of contact between two dissimilar,
 *  homogeneous materials.
 */
class ElectrostaticInsulatorComplex : public ADInterfaceKernel, public DerivativeMaterialPropertyNameInterface
{
public:
  static InputParameters validParams();

  ElectrostaticInsulatorComplex(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real & _omega;
  const ADMaterialProperty<Real> & _sigma, & _sigma_neighbor;
  const ADMaterialProperty<Real> & _eps, & _eps_neighbor;
  const ADVariableGradient & _grad_pot1im;
  const ADMaterialProperty<Real> & _D, & _D_neighbor;
  const ADVariableValue & _pot2re;
  const ADVariableGradient & _grad_pot2re;
  VariableName _pot2re_name;
  const ADMaterialProperty<Real> & _cpos;
  const MaterialPropertyName & _cpos_name;
  const ADMaterialProperty<Real> & _dcpos_dphi;
  const ADMaterialProperty<Real> & _cpos_neighbor;
  const MaterialPropertyName & _cpos_neighbor_name;
  const ADMaterialProperty<Real> &_dcpos_neighbor_dphi;
};
