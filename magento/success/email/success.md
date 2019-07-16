**Magento environment**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/)

Use the following credentials to access the admin panel:

**Admin Panel**: [${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/admin/](${globals.PROTOCOL}://${settings.envName}.${globals.REGION-0}/admin/)  
**Login**: ${user.email}  
**Password**: ${globals.ADMIN_PASS}  

Manage the database nodes using the next credentials:

**phpMyAdmin Panel**: [https://node${globals.masterDB-ID0}-${settings.envName}.${globals.REGION-0}/](https://node${globals.masterDB-ID0}-${settings.envName}.${globals.REGION-0}/)  
**Username**: ${globals.DB_USER}    
**Password**: ${globals.DB_PASS}  

