import com.hivext.api.Response;
import org.yaml.snakeyaml.Yaml;
import com.hivext.api.core.utils.Transport;

var lsAppid = "9e6afcf310004ac84060f90ff41a5test";
var baseUrl = "https://raw.githubusercontent.com/jelastic-jps/magento/master/magento";
var lsText = "Install LiteSpeed High-Performance Web Server";
var group = jelastic.billing.account.GetAccount(appid, session);

var url = baseUrl + "/configs/settings.yaml";
var settings = toNative(new Yaml().load(new Transport().get(url)));
var fields = settings.fields;
if (group.groupType == 'trial') {
    fields.push({
            caption: "Additions",
            type: "displayfield",
            name: "displayfield",
            markup: "ARE NOT AVAILABLE FOR [" + group.groupType.toUpperCase() + "] ACCOUT"
        }, {
        "type": "compositefield",
        "hideLabel": true,
        "pack": "left",
        "itemCls": "deploy-manager-grid",
        "cls": "x-grid3-row-unselected",
        "items": [{
            "type": "spacer",
            "width": 4
        }, {
            "type": "displayfield",
            "cls": "x-grid3-row-checker x-item-disabled",
            "width": 30,
            "height": 20
        }, {
            "type": "displayfield",
            "cls": "x-item-disabled",
            "value": lsText
        }]
    });
} else {

    var isLS = jelastic.dev.apps.GetApp(lsAppid);
    if (isLS.result == 0 || isLS.result == Response.PERMISSION_DENIED) {
        settings.fields.push({
            caption: "Additions",
            type: "displayfield",
            name: "displayfield",
            markup: ""
        }, {
            type: "checkbox",
            name: "ls-addon",
            caption: lsText,
            value: true
        });
    }
}

return {
    result: 0,
    settings: settings
};
