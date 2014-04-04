Introduction
===

This was made for viewing annotated WSDL files in a browser without needing any sort of server side preprocessing or modifications to the WSDL.

The WSDL to HTML conversion is done on-the-fly in the browser through [Saxon-CE](http://www.saxonica.com/ce/index.xml) and an XSLT based upon a [WSDL viewer](http://code.google.com/p/wsdl-viewer/) used within the [Apache Woden project](http://ws.apache.org/woden/index.html). That XSLT has however been modified quite a bit, both to look nicer and make it work smoothly with Saxon-CE and also to fix quite a lot of bugs and poorly written XSLT.

There are still quite a few issues and inefficiencies in the XSLT, so that is a work in progress. Do let me know if you find any, especially if you also find how to fix them ;)


Requirements
---

- Should be usable directly, but an HTTP server is recommended for stable use. Otherwise the browser may go a bit nuts with local security issues and stuff...
- The WSDL is loaded asynchronously through JavaScript by the browser so you are limited by cross-origin restricitons. This means that the WSDL Viewer and the WSDL+XSDs must have the same origin, or the WSDL+XSDs must have the Access-Control-Allow-Origin header present.

In the first usage of this, we actually just used the viewer directly from the subversion repository where both the viewer and all the WSDL files were hosted. This prevented us from having to set up another HTTP server for hosting, and also meant there were no cross-origin problems.


Usage
---

- No parameter  
Will present a form where you can paste the URL to a WSDL and load it up.
- With parameter (`?wsdl=path.to.wsdl`)  
Will start loading the given WSDL directly after the page itself has loaded.
- With parameter and hash (`?wsdl=path.to.wsdl#SomeType`)
Same as previous, but will also scroll to and highlight the element in the hash after the WSDL has been loaded.
