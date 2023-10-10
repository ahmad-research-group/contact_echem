#include "contact_echemApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
contact_echemApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

contact_echemApp::contact_echemApp(InputParameters parameters) : MooseApp(parameters)
{
  contact_echemApp::registerAll(_factory, _action_factory, _syntax);
}

contact_echemApp::~contact_echemApp() {}

void 
contact_echemApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<contact_echemApp>(f, af, s);
  Registry::registerObjectsTo(f, {"contact_echemApp"});
  Registry::registerActionsTo(af, {"contact_echemApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
contact_echemApp::registerApps()
{
  registerApp(contact_echemApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
contact_echemApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  contact_echemApp::registerAll(f, af, s);
}
extern "C" void
contact_echemApp__registerApps()
{
  contact_echemApp::registerApps();
}
