Introduction
===

This was made for viewing WSDL files which has been properly documented in a browser without having the need of any server side preprocessing.

The WSDL to HTML conversion is done on-the-fly in the browser through Saxon-CE. The XSLT it uses is based upon the [WSDL viewer](http://code.google.com/p/wsdl-viewer/) which is also used within the [Apache Woden project](http://ws.apache.org/woden/index.html), but it has been modified quite a bit. Both to make it work smoothly with Saxon-CE and look nicer, but also to fix quite a lot of bugs and poorly written XSLT. The last bit is a work in progress, as there are still some things that doesn't seem to work as they should or just work terribly inefficient.




Requirements
---

- Needs to be hosted on an HTTP server for stable use, otherwise the browser will probably go nuts from local security rules and such
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
