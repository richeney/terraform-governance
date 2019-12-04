# Azure Governance using Terraform

## Description

Example set of Terraform files for configuring core governance guard rails:

* [Management Groups](https://docs.microsoft.com/en-us/azure/governance/management-groups/)
* [Azure Policy](https://docs.microsoft.com/azure/governance/policy/)
  * Custom Policy definitions
  * Custom Policy Initiative definitions
  * Policy Assignments
* [Role Based Access Control](https://docs.microsoft.com/azure/role-based-access-control/)
  * RBAC Assignments

This repo is a technical proof of concept.  The Terraform configuration may be applied to either greenfield or brownfield deployments.  However, any use against production environments is at your own risk. Note that the files are not provided as a full set of what is required for your organisation or customers, but is intended to showcase some of the core control types.

Terraform destroy will put everything back to how it was. (Caveat: see [issues](#issues) below.)

## Pre-requirements

You will need access to the AAD Global Admin ID for the tenancy. It is assumed that you are already familiar with Terraform on Azure.

## Elevating Access

Creating Management Groups requires elevated access. This creates the Root Tenant Group and assigns the Global Admin as User Access Administrator at the new scope point.

* Elevate the AAD Global Admin to as per the [documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin#azure-portal)

You can then either run the terraform commands as the Global Admin user, or create a service principal to do so.

## Running as the Global Admin

* Ensure the logged in user is running the commands by ensuring that the Terraform environment variables are unset

    ```bash
    unset ARM_SUBSCRIPTION_ID ARM_TENANT_ID ARM_CLIENT_SECRET ARM_CLIENT_ID
    ```

* Skip to the [Terraform Workflow](#terraform-workflow) section

## Service Principal Configuration (for CI/CD pipelines)

The repo needs a service principal that has access to the Root Tenant Group for management group creation. It may be prudent to make this a separate service principal to the ones used for standard resource deployments at the subscription and resource group level.

The following steps are based on the management group [documentation](https://docs.microsoft.com/en-us/azure/governance/management-groups/overview#root-management-group-for-each-directory).

* Elevate the AAD Global Admin to as per the [documentation](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin#azure-portal)

* Create a service principal for governance, storing the output

    ```bash
    ~ $ az ad sp create-for-rbac --name http://Governance --skip-assignment --output json | tee /tmp/sp.json
    ```

    Example output:

    ```json
    {
        "appId": "7bd0f5d7-6e82-40bb-81c9-3db265e83684",
        "displayName": "Governance",
        "name": "http://Governance",
        "password": "5ebb1a74-c140-4adf-ae2c-4ea07dae0939",
        "tenant": "f246eeb7-b820-4971-a083-9e100e084ed0"
    }
    ```

* Export the environment variables for the [Terraform azurerm provider](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html#configuring-the-service-principal-in-terraform)

    ```bash
    export ARM_CLIENT_ID=$(jq -r .appId sp.json)
    export ARM_CLIENT_SECRET=$(jq -r .password sp.json)
    export ARM_TENANT_ID=$(jq -r .tenant sp.json)
    export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    ```

* Delete the credentials JSON (_recommended_)

    ```bash
    rm /tmp/sp.json
    ```

* Add the environment variables to your .bashrc file (_recommended_)

    Copy and paste the code block below to add the commands to your ~/.bashrc file:

    ```bash
    cat >> ~/.bashrc <<EOF
    export ARM_CLIENT_ID=$ARM_CLIENT_ID
    export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
    export ARM_TENANT_ID=$ARM_TENANT_ID
    export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
    EOF
    ```

    Adding the lines to your profile will ensure the environment variables persist between sessions.

* Determine the Tenant Root Group's ID

    ```bash
    trgId=/providers/Microsoft.Management/managementGroups/$ARM_TENANT_ID
    ```

* Assign the Management Group Contributor role for the service principal

    The Governance service principal needs Management Group Contributor for the resources in mg.tf.

    ```bash
    az role assignment create --assignee http://Governance --scope $trgId --role 5d58bcaf-24a5-4b20-bdb6-eed9f69fbe4c
    ```

* Assign Resource Policy Contributor role

    The resources in custom_policies.tf, custom_initiatives.tf and policy_assignments.tf require Resource Policy Contributor.

    ```bash
    az role assignment create --assignee http://Governance --scope $trgId --role 36243c78-bf99-498c-9df9-86d9f8d28608
    ```

* Additional access to enable RBAC assignments

    > Azure Lighthouse is the recommended way for customers to delegate access for managed service providers

    For the Governance service principal to assign roles at the management group scope then the service principal needs an RBAC role capable of assigning roles such as Owner or User Access Administrator.

    If you are also dynamically looking up the object IDs for your security principals and groups then you will need additional API permissions for the service principal to be able to read AAD.

* Assign the User Access Administrator role (for azurerm_role_assignment):

    ```bash
    az role assignment create --assignee http://Governance --scope $trgId --role 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9
    ```

    > This is all that is required for assignments if you use the GUIDs for the security groups in AAD rather than data azuread_group

* Add API permissions to read the legacy AAD directory (for data.azuread_group)

    Find the App ID and add the API permission to that the service principal can read the groups in AAD.

    ```bash
    appId=$(az ad sp show --id "http://governance" --query appId --output tsv)
    az ad app update --id $appId --required-resource-accesses @read.aad.json
    ```

    The API permissions can be seen at the [App Registration](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps) level. Find the http://Governance app ID and view both API Permissions and the Manifest.

    The read.aad.json contains

    ```json
    [
        {
            "resourceAppId": "00000002-0000-0000-c000-000000000000",
            "resourceAccess": [
                {
                    "id": "5778995a-e1bf-45b8-affa-663a9f3f4d04",
                    "type": "Role"
                }
            ]
        }
    ]
    ```

    This JSON matches the requiredResourceAccess section in the Manifest.

## Terraform Workflow

Once the credentials have the correct authority then testing or demoing is a matter of running through the standard Terraform workflow.

* Initialise

    ```bash
    terraform init
    ```

* Plan

    ```bash
    terraform plan
    ```

* Apply

    ```bash
    terraform apply
    ```

    Use the `-auto-approve` to skip the approval step.

* Revert

    ```bash
    terraform destroy
    ```

## Issues

The azurem_management_group resource type supports arrays of subscription IDs, but there is an [open Terraform bug](https://github.com/terraform-providers/terraform-provider-azurerm/issues/3450) as `terraform destroy` will generate an error. The subscriptions may be moved under management groups in the portal.

Alternatively, the mg.tf can be updated to automatically place subscription. (Example GUIDS or first class expressions are shown in comments.) If using `terraform destroy` then first move the subscriptions back up to the Root Tenant Group (using the portal or CLI commands) and then comment out the

## Planned

A future version of this lab will include least privilege and wil make use of Privileged Identity Management for just enough access (JEA) and just in time (JIT) access.

The custom policy and policy initiative definitions will be moved into a separate GitHub repo so that it can be called as a module.  It is likely that a managed service provider will standardise the policy initiatives centrally. The customer specific Terraform files can selectively assign, using parameterisation to customise values.
