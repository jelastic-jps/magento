vcl 4.0;
import std;
import directors;

sub vcl_init {
	new myclust = directors.round_robin();
}
sub vcl_deliver {
        if (obj.hits > 0) {
                set resp.http.X-Cache = "HIT";
        } else {
                set resp.http.X-Cache = "MISS";
        }
}

sub vcl_recv {
        if (req.http.Upgrade ~ "(?i)websocket") {
                set req.backend_hint = myclust.backend();
                return (pipe);
        }
        else {
                set req.backend_hint = myclust.backend();
        }

     if (req.method != "GET" &&
        	req.method != "HEAD" &&
        	req.method != "PUT" &&
        	req.method != "POST" &&
        	req.method != "TRACE" &&
        	req.method != "OPTIONS" &&
        	req.method != "DELETE") {
          /* Non-RFC2616 or CONNECT which is weird. */
          return (pipe);
    	}

    	# We only deal with GET and HEAD by default
    	if (req.method != "GET" && req.method != "HEAD") {
          return (pass);
    	}

return (hash);
}

sub vcl_backend_response {

	if (beresp.ttl <= 0s ||
		beresp.http.Set-Cookie ||
		beresp.http.Surrogate-control ~ "no-store" ||
		(!beresp.http.Surrogate-Control &&
		beresp.http.Cache-Control ~ "no-cache|no-store|private") ||
		beresp.http.Vary == "*") {
		/*
		 * Mark as "Hit-For-Pass" for the next 2 minutes
		 */
		set beresp.ttl = 120s;
		set beresp.uncacheable = true;
	}

	# For static content strip all backend cookies and push to static storage

	if (bereq.url ~ "\.(jp(e?)g)|png|gif|ico|webp|js|css|txt|pdf|gz|zip|lzma|bz2|tgz|tbz") {
                unset beresp.http.cookie;
               	set beresp.storage_hint = "static";
               	set beresp.http.x-storage = "static";
       		set beresp.ttl = 8h; #Caching 8h
	} else {
                set beresp.storage_hint = "default";
               	set beresp.http.x-storage = "default";
        	set beresp.ttl = 30s; #Altrimenti caching default 30s
	}

return (deliver);

}

#sub vcl_synth {

    # ..... REWRITE HTTP to HTTPS .....
#    if (resp.status == 750) {
#        set resp.status = 301;
#        set resp.http.Location = "https://" + req.http.host + req.url;
#        return(deliver);
#    }
#}

sub vcl_deliver {
  if (resp.http.X-Magento-Debug) {
      if (obj.hits > 0) {
          set resp.http.X-Magento-Cache-Debug = "HIT";
      } else {
          set resp.http.X-Magento-Cache-Debug = "MISS";
      }
  } else {
      unset resp.http.Age;
  }

  if (resp.http.magicmarker) {
      unset resp.http.magicmarker;
	    # By definition we have a fresh object
	    set resp.http.Age = "0";
  }

  set resp.http.X-Cache-Hits = obj.hits;

  # Set Varnish server name
  set resp.http.X-Served-By = server.hostname;
  #set resp.http.X-Backend-Key = req.backend;

  # Remove some headers: PHP version
  unset resp.http.X-Powered-By;

  #Set header
  set resp.http.X-Powered-By = "neen";
  set resp.http.Cache-Control = "no-cache, no-store, must-revalidate";
  set resp.http.Expires = "0";
  set resp.http.Pragma = "no-cache";
  #Unset header
  unset resp.http.Server;
  unset resp.http.X-Varnish;
  unset resp.http.Via;
  unset resp.http.Link;
  unset resp.http.X-Generator;
  unset resp.http.X-Magento-Debug;
  unset resp.http.X-Magento-Tags;

return (deliver);
}
