import com.hivext.api.Response;
import org.yaml.snakeyaml.Yaml;
import com.hivext.api.core.utils.Transport;

var cdnAppid = "c05ffa5b45628a2a0c95467ebca8a0b4";
var lsAppid = "9e6afcf310004ac84060f90ff41a5aba";
var group = jelastic.billing.account.GetAccount(appid, session);
var isCDN = jelastic.dev.apps.GetApp(cdnAppid);
var isLS = jelastic.dev.apps.GetApp(lsAppid);

var settings = jps.settings;
var fields = {};
for (var i = 0, field; field = jps.settings.fields[i]; i++)
  fields[field.name] = field;
 
if (isLS.result == 0 || isLS.result == Response.PERMISSION_DENIED) {  
  fields["ls_addon"].hidden = false;
  fields["ls_addon"].value = true;
} else {
  fields["ls_addon"].hidden = true;
  fields["ls_addon"].value = false;
  fields["ls_addon"].showIf = null;
}
  
if (isCDN.result == 0 || isCDN.result == Response.PERMISSION_DENIED) {
  fields["cdn_addon"].hidden = false;
  fields["cdn_addon"].value = true;
} else {
  fields["cdn_addon"].hidden = true;
  fields["cdn_addon"].value = false;
}

//checking quotas
var extIP = "environment.externalip.enabled",
    extIPperEnv = "environment.externalip.maxcount",
    extIPperNode = "environment.externalip.maxcount.per.node",
    maxCloudletsPerRec = "environment.maxcloudletsperrec",
    maxEnvs = "environment.maxcount",
    envsCount = jelastic.env.control.GetEnvs({lazy: true}).infos.length,
    markup = "", cur = null, text = "used", LE = true, prod = true;

var quotas = jelastic.billing.account.GetQuotas(extIP + ";"+extIPperEnv+";" + extIPperNode +";" + maxCloudletsPerRec +";" + maxEnvs).array;
for (var i = 0; i < quotas.length; i++){
    var q = quotas[i], n = toNative(q.quota.name);
  
    if (n == maxEnvs && envsCount >= q.value){
        err(q, "already used", envsCount, true);
        prod = false; break;
    }

    if (n == maxCloudletsPerRec && q.value < 32){
        if (!markup) err(q, "required", 32, true);
        prod = false;
    }

    if (n == extIP &&  !q.value){
        if (!markup) err(q, "required", 1, true);
        LE  = false; 
    }
    
    if (n == extIPperEnv && q.value < 1){
        if (!markup) err(q, "required", 1, true);
        LE = false;
    }

   if (n == extIPperNode && q.value < 1){
        if (!markup) err(q, "required", 1, true);
        LE = false;
    }
}

if (!LE) {
  fields["displayfield"].markup = "Some advanced features are not available. Please upgrade your account.";
  fields["displayfield"].cls = "warning";
  fields["displayfield"].hideLabel = true;
  fields["displayfield"].height = 25;
  fields["le_addon"].disabled = true;
  fields["le_addon"].value = false;
  fields["bl_count"].markup = "Let's Encrypt is not available. " + markup + "Please upgrade your account.";
  fields["bl_count"].cls = "warning";
  fields["bl_count"].hidden = false;
  fields["bl_count"].height = 30;  
}

if (!prod) {
  fields["bl_count"].markup = "Magento standalone is not available. " + markup + "Please upgrade your account.";
  fields["bl_count"].cls = "warning";
  fields["bl_count"].hidden = false;
  fields["bl_count"].height = 30;
  
  settings.fields.push(
    {"type": "compositefield","height": 0,"hideLabel": true,"width": 0,"items": [{"height": 0,"type": "string","required": true}]}
  );
}

return {
    result: 0,
    settings: settings
};

function err(e, text, cur, override){
  var m = (e.quota.description || e.quota.name) + " - " + e.value + ", " + text + " - " + cur + ". ";
  if (override) markup = m; else markup += m;
}
