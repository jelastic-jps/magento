var resp = {
  result: 0,
  nodes: []
}

if ('${settings.ls_addon:false}'== 'true') {
  resp.nodes.push({
    nodeType: "llsmp",
    tag: "6.0.2-php-7.4.20",
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    nodeGroup: "cp",
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
    tag: "1.18.0-php-7.4.20",
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
    ELASTIC_PASSWORD: "${globals.ES_PASS}",
    JELASTIC_EXPOSE: "9200"
  }
})

return resp;
