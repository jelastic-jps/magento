var resp = {
  result: 0,
  nodes: []
}

if ('${settings.ls_addon:false}'== 'true') {
  resp.nodes.push({
    nodeType: "llsmp",
    tag: "5.4.11-php-7.4.13",
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    nodeGroup: "cp",
    addons: ["setup-site-url"],
    links: "elasticsearch:elasticsearch",
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true",
      WAF: "${settings.waf:false}",
      WP_PROTECT: "OFF",
      ON_ENV_INSTALL: {
        jps: "https://raw.githubusercontent.com/jelastic-jps/litespeed/master/addons/license-v2.yml",
        settings: {
          lm: "true",
          modules: "litemagestandard"
        }
      }
    }
  })
} else {
  resp.nodes.push({
    nodeType: "lemp",
    engine: "php7.4",
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},                  
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    nodeGroup: "cp",
    addons: ["setup-site-url"],
    links: "elasticsearch:elasticsearch",
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true"
    }
  })
}

resp.nodes.push({
  nodeType: "docker",
  count: 1,
  flexibleCloudlets: ${settings.st_flexibleCloudlets:16},
  fixedCloudlets: ${settings.st_fixedCloudlets:1},
  nodeGroup: "elasticsearch",
  dockerName: "elasticsearch",
  dockerTag: "7.12.1",
  displayName: "Elasticsearch",
  env: {
    ES_JAVA_OPTS: "-Xms512m -Xmx512m",
    ELASTIC_PASSWORD: "${globals.ES_PASS}"
  }
})

return resp;
