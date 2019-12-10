resource "azurerm_policy_definition" "auditemptytagvalue" {
    name         = "auditEmptyTagValue"
    display_name = "Audit tag exists and has a value"
    description  = "This policy audits that a tag exists and has a non-empty value."
    policy_type  = "Custom"
    mode         = "Indexed"

    management_group_id = "${data.azurerm_client_config.current.tenant_id}"

    parameters = <<PARAMETERS
    {
        "tagName": {
            "type": "String",
            "metadata": {
                "description": "Name of the tag, e.g. 'Environment'",
                "displayName": "Tag Name"
            }
        }
    }
PARAMETERS

    policy_rule = <<POLICY_RULE
    {
        "if": {
            "anyOf": [
                {
                    "exists": "false",
                    "field": "[concat('tags[', parameters('tagName'), ']')]"
                },
                {
                    "field": "[concat('tags[', parameters('tagName'), ']')]",
                    "match": ""
                }
            ]
        },
        "then": {
            "effect": "audit"
        }
    }
POLICY_RULE
}

resource "azurerm_policy_definition" "audittagvaluefromlist" {
    name         = "auditTagValueFromList"
    display_name = "Audit tag exists and has a value from the allowedList"
    description  = "This policy audits that a tag exists and has a value from the specified list."
    policy_type  = "Custom"
    mode         = "Indexed"

    management_group_id = "${data.azurerm_client_config.current.tenant_id}"

    parameters = <<PARAMETERS
    {
        "tagName": {
            "metadata": {
                "description": "Name of the tag, such as 'costcode'",
                "displayName": "Tag Name"
            },
            "type": "String"
        },
        "tagValues": {
            "metadata": {
                "description": "The list of permitted tag values",
                "displayName": "Permitted Tag Values"
            },
            "type": "Array"
        }
    }
PARAMETERS

    policy_rule = <<POLICY_RULE
    {
        "if": {
            "anyOf": [
                {
                    "field": "[concat('tags[', parameters('tagName'), ']')]",
                    "exists": "false"
                },
                {
                    "field": "[concat('tags[', parameters('tagName'), ']')]",
                    "notIn": "[parameters('tagValues')]"
                }
            ]
        },
        "then": {
            "effect": "audit"
        }
    }
POLICY_RULE
}

resource "azurerm_policy_definition" "audittagvaluepattern" {
    name         = "auditTagValuePattern"
    display_name = "Audit tag exists and that the value matches the pattern"
    description  = "This policy audits that a tag exists and has a value that matches the specified pattern."
    policy_type  = "Custom"
    mode         = "Indexed"

    management_group_id = "${data.azurerm_client_config.current.tenant_id}"

    parameters = <<PARAMETERS
    {
        "tagName": {
            "type": "String",
            "metadata": {
                "description": "Name of the tag, e.g. 'Costcode'",
                "displayName": "Tag Name"
            }
        },
        "tagValuePattern": {
            "type": "String",
            "metadata": {
                "description": "Pattern to use for names. Use ? for characters and # for numbers.",
                "displayName": "Tag Value Pattern"
            }
        }
    }
PARAMETERS

    policy_rule = <<POLICY_RULE
    {
        "if": {
            "not": {
                "field": "[concat('tags.', parameters('tagName'))]",
                "match": "[parameters('tagValuePattern')]"
            }
        },
        "then": {
            "effect": "audit"
        }
    }
POLICY_RULE
}