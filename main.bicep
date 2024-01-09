// https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/bicep-import#import-user-defined-data-types-preview

// import all variables from variables.bicep with wildcard
import * as vars from './variables.bicep'

// you can import each variable separately as well
// import { location, suffix, hubVnetPrefix } from './variables.bicep'

// import type parameter to restrict the value of user imput parameter
import { tag as tagchoice } from './variables.bicep'
param tag tagchoice

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-${vars.suffix}'
  location: vars.location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  tags: {
    Environment: tag
  }
}

resource vpnVNet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-${vars.suffix}'
  location: vars.location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vars.hubVnetPrefix
      ]
    }
    subnets: [
      {
        name: 'subnet-001'
        properties: {
          addressPrefix: vars.subnetPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
  tags: {
    Environment: tag
  }
}
