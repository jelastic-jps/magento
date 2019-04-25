## CORS issue fixing

Installing Edgeport - Premium CDN Add-On on Magento 2 application, you will be experiencing [**Cross-Origin Resource Sharing (CORS)**](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) issue which is invoked when a web application executes a cross-origin HTTP request when it requests a resource that has a different origin (domain, protocol, and port) than its own origin.
      
There are several ways how to overcome this issue. One of them we describe here.
   
1. Upload **cors.conf** file from repository directory **CDN-CORS** to **/etc/nginx/** directory.
   
2. Open **cors.conf** , find line #5 and replace **magentohostname** with your environment hostname and **magentocdnhostname** with magento CDN hostname obtained upon Add-On installation.
   
For example: **if ($http_origin ~* 'https?://(localhost|magento\\.jelastic\\.com|magento\\.cdn\\.edgeport\\.net)')** 
   
3. Replace **/etc/nginx/conf.d/site-default.conf** with **site-default.conf** from repository directory **CDN-CORS**.
   
4. The changes added as lines **67, 79** and **104** to **site-default.conf**.