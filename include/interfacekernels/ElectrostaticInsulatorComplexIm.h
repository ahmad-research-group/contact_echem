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
#include "Function.h"

/**
 *  This ADInterfaceKernel object calculates the electrostatic potential value
 *  and gradient relationship as a result of contact between two dissimilar,
 *  homogeneous materials.
 */
class ElectrostaticInsulatorComplexIm : public ADInterfaceKernel
{
public:
  static InputParameters validParams();

  ElectrostaticInsulatorComplexIm(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual(Moose::DGResidualType type) override;

  const Real & _omega;
  const ADMaterialProperty<Real> & _sigma;
  const ADMaterialProperty<Real> & _eps;
  const ADMaterialProperty<Real> & _eps_neighbor;
  const ADVariableGradient & _grad_pot1re;

};
