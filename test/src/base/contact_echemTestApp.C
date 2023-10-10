//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "contact_echemTestApp.h"
#include "contact_echemApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
contact_echemTestApp::validParams()
{
  InputParameters params = contact_echemApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

contact_echemTestApp::contact_echemTestApp(InputParameters parameters) : MooseApp(parameters)
{
  contact_echemTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

contact_echemTestApp::~contact_echemTestApp() {}

void
contact_echemTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  contact_echemApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"contact_echemTestApp"});
    Registry::registerActionsTo(af, {"contact_echemTestApp"});
  }
}

void
contact_echemTestApp::registerApps()
{
  registerApp(contact_echemApp);
  registerApp(contact_echemTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
contact_echemTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  contact_echemTestApp::registerAll(f, af, s);
}
extern "C" void
contact_echemTestApp__registerApps()
{
  contact_echemTestApp::registerApps();
}
