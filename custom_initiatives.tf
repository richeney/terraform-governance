locals {
  allowedLocations            = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  allowedVirtualMachineSkus   = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
  appendTagAndItsDefaultValue = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  requireTagAndItsValue       = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  // tenantRootGroupCustomPolicy = "/providers/Microsoft.Management/managementgroups/${var.tenantId}/providers/Microsoft.Authorization/policyDefinitions"
}

resource "azurerm_policy_set_definition" "deny" {
  name         = "Deny"
  policy_type  = "Custom"
  display_name = "Standard Deny Policy Initiative"
  description  = "Limit the permitted regions and virtual machine SKUs"

  management_group_id = data.azurerm_client_config.current.tenant_id

  /*
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  */

  parameters = <<PARAMETERS
    {
        "regions": {
            "type": "Array",
            "metadata": {
                "displayName": "List of regions",
                "description": "List of permitted region. Only permitted pairs as West / North Europe or UK South / West."
            },
            "defaultValue": [
                "West Europe",
                "North Europe"
            ],
            "allowedValues": [
                [
                    "West Europe",
                    "North Europe"
                ],
                [
                    "UK South",
                    "UK West"
                ]
            ]
        }
    }
PARAMETERS


  policy_definitions = <<POLICY_DEFINITIONS
    [
        {
            "comment": "Permitted regions",
            "parameters": {
                "listOfAllowedLocations": {
                    "value": "[parameters('regions')]"
                }
            },
            "policyDefinitionId": "${local.allowedLocations}"
        },
        {
            "comment": "Permitted VM SKUs. Non-compliant SKUs will be denied.",
            "parameters": {
                "listOfAllowedSKUs": {
                    "value": [
                        "Standard_B1ms",
                        "Standard_B1s",
                        "Standard_B2ms",
                        "Standard_B2s",
                        "Standard_B4ms",
                        "Standard_D2_v3",
                        "Standard_D2s_v3"
                    ]
                }
            },
            "policyDefinitionId": "${local.allowedVirtualMachineSkus}"
        }
    ]
POLICY_DEFINITIONS

}

resource "azurerm_policy_set_definition" "tags" {
  name         = "Tags"
  policy_type  = "Custom"
  display_name = "Standard Tagging Policy Initiative"

  metadata     = <<METADATA
    {
        "category": "Tags"
    }
METADATA

  management_group_id = data.azurerm_client_config.current.tenant_id

  /*
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  */

  parameters = <<PARAMETERS
    {
        "Environment": {
            "type": "String",
            "metadata": {
                "description": "Environment, from permitted list",
                "displayName": "Environment"
            },
            "defaultValue": "Dev",
            "allowedValues": [
                "Prod",
                "UAT",
                "Test",
                "Dev"
            ]
        }
    }
PARAMETERS


  policy_definitions = <<POLICY_DEFINITIONS
    [
        {
            "comment": "Create Owner tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Owner"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Audit Owner tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Owner"
                }
            },
            "policyDefinitionId": "${azurerm_policy_definition.auditemptytagvalue.id}"
        },
        {
            "comment": "Create Department tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Department"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Check if Department is in the defined list",
            "parameters": {
                "tagName": {
                    "value": "Department"
                },
                "tagValues": {
                    "value": [
                        "Finance",
                        "Human Resources",
                        "Logistics",
                        "Sales",
                        "IT"
                    ]
                }
            },
            "policyDefinitionId": "${azurerm_policy_definition.audittagvaluefromlist.id}"
        },
        {
            "comment": "Create Application tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Application"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Audit Application tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Application"
                }
            },
            "policyDefinitionId": "${azurerm_policy_definition.auditemptytagvalue.id}"
        },
        {
            "comment": "Create Environment tag with parameters value if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Environment"
                },
                "tagValue": {
                    "value": "[parameters('Environment')]"
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Deny Environment tag if it isn't set to the parameter",
            "parameters": {
                "tagName": {
                    "value": "Environment"
                },
                "tagValue": {
                    "value": "[parameters('Environment')]"
                }
            },
            "policyDefinitionId": "${local.requireTagAndItsValue}"
        },
        {
            "comment": "Create Downtime tag if it does not exist, with default value",
            "parameters": {
                "tagName": {
                    "value": "Downtime"
                },
                "tagValue": {
                    "value": "Tuesday, 04:00-04:30"
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Audit Downtime tag if it is empty",
            "parameters": {
                "tagName": {
                    "value": "Downtime"
                }
            },
            "policyDefinitionId": "${azurerm_policy_definition.auditemptytagvalue.id}"
        },
        {
            "comment": "Create Costcode tag if it does not exist",
            "parameters": {
                "tagName": {
                    "value": "Costcode"
                },
                "tagValue": {
                    "value": ""
                }
            },
            "policyDefinitionId": "${local.appendTagAndItsDefaultValue}"
        },
        {
            "comment": "Check that Costcode tag value is a six digit number",
            "parameters": {
                "tagName": {
                    "value": "Costcode"
                },
                "tagValuePattern": {
                    "value": "######"
                }
            },
            "policyDefinitionId": "${azurerm_policy_definition.audittagvaluepattern.id}"
        }
    ]
POLICY_DEFINITIONS
}
