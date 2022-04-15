var resp = {
  result: 0,
  nodes: []
}

if ('${settings.ls_addon:false}'== 'true') {
  resp.nodes.push({
    nodeType: "llsmp",
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    nodeGroup: "cp",
    links: "elasticsearch:elasticsearch",
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true",
      WAF: "${settings.waf:false}",
      WP_PROTECT: "OFF",
      LITEMAGE: "ON",
      ON_ENV_INSTALL: {
        jps: "https://raw.githubusercontent.com/jelastic-jps/litespeed/master/addons/license-v2.yml",
        settings: {
          lm: "true",
          modules: "litemage",
          workers: 1,
          domains: 5
        }
      }
    }
  })
} else {
  resp.nodes.push({
    nodeType: "lemp",
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},                  
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    nodeGroup: "cp",
    links: "elasticsearch:elasticsearch",
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true"
    }
  })
}

resp.nodes.push({
  nodeType: "opensearch",
  count: 1,
  flexibleCloudlets: ${settings.st_flexibleCloudlets:16},
  fixedCloudlets: ${settings.st_fixedCloudlets:1},
  nodeGroup: "nosqldb",
  displayName: "OpenSearch",
  cluster: {
    is_opensearchdashboards: false,
    success_email: false,
  }
})

return resp;
