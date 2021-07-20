# Check Point CME Helper
These scripts can be used to expand the automation capabilities of CME created gateways (Auto Scaled Gateways) by executing commands on both the Management server and Gateway.

## CME Configuration
- autoprov_cfg set management -cs /home/admin/cme_helper.sh
- autoprov_cfg set template -tn <Template Name> <Enabled Blades> -cg /home/admin/gw_helper.sh
 
## Order of Operations
- CME Detects and Creates Gateway Object
- Restrictive Policy Installed to Gateway
- Standard Polcy Installed to Gateway
- cme_helper.sh is executed on managamenet server
- gw_helper.sh is executed on gateway

## cme_helper.sh
Management side script for customization of the created gateway object.

## gw_helper.sh
Gateway side script (optional) for customizing any additional parameters after policy installation.


