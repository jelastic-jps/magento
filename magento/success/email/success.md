**Magento environment**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-DOMAIN}/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-DOMAIN}/)

Use the following credentials to access the admin panel:

**Admin Panel**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-DOMAIN}/admin/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-DOMAIN}/admin/)  
**Login**: admin  
**Password**: ${globals.ADMIN_PASS}  

Manage the database nodes using the next credentials:

**phpMyAdmin Panel**: [https://node${globals.masterDB-ID}-${settings.envName}.${globals.REGION-DOMAIN}/](https://node${globals.masterDB-ID0}-${settings.envName}.${globals.REGION-DOMAIN}/)  
**Username**: ${globals.DB_USER}    
**Password**: ${globals.DB_PASS}  

