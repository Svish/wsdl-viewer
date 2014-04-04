// TODO: XSLT for esbp to root sequence diagram?

var xslt;

var onSaxonLoad = function() 
{
	// Initialize XSLT processor
	Saxon.setErrorHandler(onWsdlError);
	xslt = Saxon.newXSLT20Processor(Saxon.requestXML("wsdl-viewer.xsl"));
	xslt.setSuccess(onWsdlLoaded);
	
	// Load WSDL if in query string
	$(function()
	{
		var url = location.search.replace(/^\?(\w+=)?/, '');
		if(url)
		{
			url = urldecode(url);
			var name = url.match(/([^\/]+)\.\w+$/)[1];

			$('#output')
				.html('<p class="info"><span>Loading:</span> '+url+'<br/><small>May take a short while for very large WSDLs...</small></p>');

			setTimeout(loadWsdl, 250, name, url);
		}
	})
};

function loadWsdl(name, url)
{
	if( ! isSameOrigin(url))
		return onWsdlError({
			level: 'SEVERE',
			message: ': A network error occurred. Likely caused by this page and the WSDL not sharing the same origin and no "Access-Control-Allow-Origin" header present on the requested resource. Check browser console for more details.',
		})
	xslt.setParameter("", "title", name);
	xslt.updateHTMLDocument(Saxon.requestXML(url));
}

function isSameOrigin(url)
{
	var ajaxRequest = $.ajax({
		type: 'HEAD',
		url: url,
		async: false,
	});
	return ajaxRequest.status !== 0;
}

function urldecode(str)
{
	str += '';
	return decodeURIComponent(str.replace(/\+/g, '%20'));
}

function onWsdlLoaded()
{
	createToc();

	$('footer')
		.fadeIn();
	
	$('a[href*=#]')
		.on('click', onAnchorClick);
	
	scrollTo(location.hash);
}

function onWsdlError(e)
{
	$('#output')
		.append('<p class="info error"><span>'+e.level+':</span> '+e.message.match(/:\s+(.+)/)[1]+'</p>');
}

function onAnchorClick()
{
	return ! scrollTo(this.hash);
}

function createToc()
{
	$('section')
		.each(function()
		{
			var header = $('<h3>').text($('h2', this).text());
			var items = $('<ul>');

			$('div.thing', this)
				.each(function()
				{
					items.append('<li><a href="#'+this.id+'">'+$('h3', this).text()+'</a></li>');
				})

			$('<section>')
				.append(header)
				.append(items)
				.appendTo('#toc');
		})
}

function scrollTo(target)
{
	var e = $(target);
	var y = e.exists() ? e.offset().top : 0;

	if(Math.max($('html').scrollTop(), $('body').scrollTop()) != y)
		$('html,body')
			.animate({scrollTop: y}, 500, function(){mark(target);});
	else
		mark(target);

	return true;
}

function mark(target)
{
	location.hash = target;
	$('div').removeClass('target');
	$(target).addClass('target');
}

$.fn.exists = function()
{
	return this.length > 0 ? this : false;
}
