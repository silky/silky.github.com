var VoronoiLinks = {
	voronoi: new Voronoi(),
	sites: [],
	diagram: null,
	margin: 0.1,
	canvas: null,
	bbox: {xl:0,xr:800,yt:0,yb:600},
	lastCell: undefined,
	lastStyle: undefined,
	treemap: null,
	dataSrc: null,
	lastNumber: -1,

	init: function() {
		this.canvas = document.getElementById('voronoiCanvas');
		this.loadLinkData(); // will call updateData
	},
	
	updateData: function (data) {
		this.dataSrc = data;
		
		if( !data ){
			return;
		}
		
		if( data.length != this.lastNumber || this.lastNumber == -1 ){
			this.doRender();
			this.lastNumber = data.length;
		}
	},
	
	doRender: function () {
		this.randomSites(this.dataSrc.length, true);
		this.render();
	},

	clearSites: function() {
		this.sites = [];
		this.treemap = null;
		this.diagram = this.voronoi.compute(this.sites, this.bbox);
		this.updateStats();
		},

		
	drawCells: function() {
		var colvalues = '0123456789ABCDEF';
		var ctx = this.canvas.getContext('2d');	
		this.voronoi.closeCells(this.bbox);
		var cells = this.diagram.cells;
		if (!cells) {return;}
		var halfedges, nHalfedges, iHalfedge;
		var v;
		
		var initialRnd = Math.random();
		
		for (var cellid in cells) {
			halfedges = cells[cellid].halfedges;
			nHalfedges = halfedges.length;
			//this.assert(nSegments > 0);
			v = halfedges[0].getStartpoint();
			ctx.beginPath();
			ctx.moveTo(v.x,v.y);
			for (iHalfedge=0; iHalfedge<nHalfedges; iHalfedge++) {
				v = halfedges[iHalfedge].getEndpoint();
				ctx.lineTo(v.x,v.y);
				}
			
			// seed a rng from the hash of the email.
			// if( !window.location.search.startsWith("?unique") ){
				// email = this.dataSrc[cellid]["author"]["email"];
				// Math.seedrandom(email + initialRnd);
			// }
			
			ctx.fillStyle='#'+colvalues[(Math.random()*16)&15]+colvalues[(Math.random()*16)&15]+colvalues[(Math.random()*16)&15];
			ctx.fill();
			}
		},
		
		
	randomSites: function(n,clear) {
		if (clear) {this.sites = [];}
		// create vertices
		var xmargin = this.canvas.width*this.margin,
			ymargin = this.canvas.height*this.margin,
			xo = xmargin,
			dx = this.canvas.width-xmargin*2,
			yo = ymargin,
			dy = this.canvas.height-ymargin*2;
		for (var i=0; i<n; i++) {
			this.sites.push({x:self.Math.round((xo+self.Math.random()*dx)*10)/10,y:self.Math.round((yo+self.Math.random()*dy)*10)/10});
			}
		this.treemap = null;
		this.diagram = this.voronoi.compute(this.sites, this.bbox);
		this.updateStats();
		},

	arbitraryAction: function(ev) {
		cellid = this.getCellUnderMouse(ev);
		var href = this.dataSrc[cellid]["link"];
		window.open(href);
		},

	updateStats: function() {
		if (!this.diagram) {return;}
		var e = document.getElementById('voronoiStats');
		if (!e) {return;}
	},
		
	buildTreemap: function() {
		var treemap = new QuadTree({
			x: this.bbox.xl,
			y: this.bbox.yt,
			width: this.bbox.xr-this.bbox.xl,
			height: this.bbox.yb-this.bbox.yt
			});
		var cells = this.diagram.cells,
			iCell = cells.length;
		// iterate through all cells
		while (iCell--) {
			bbox = cells[iCell].getBbox();
			bbox.cellid = iCell;
			treemap.insert(bbox);
			}
		return treemap;
		},

	updateInformation: function(ev) {
		cellid = this.getCellUnderMouse(ev);
		if (this.lastCell !== cellid) {
			if (this.lastCell !== undefined) {
				this.renderCell(this.lastCell, undefined, '#fff');
				}
			if (cellid !== undefined) {
				this.renderCell(cellid, undefined, '#00f');
				}
			this.lastCell = cellid;
			}
		
		var dataBit = this.dataSrc[cellid];
		var name  = dataBit["name"];
		var link = dataBit["link"];
		$("#voronoiCellid").html(name + " - " + link);
	},
	
	getCellUnderMouse: function(ev) {
		if (!this.diagram) {return;}
		var canvas = document.getElementById('voronoiCanvas');
		if (!canvas) {
			return;
			}
		// >>> http://www.quirksmode.org/js/events_properties.html#position
		var x = 0,
			y = 0;
		if (!ev) {
			ev = window.event;
			}
		if (ev.pageX || ev.pageY) {
			x = ev.pageX;
			y = ev.pageY;
			}
		else if (e.clientX || e.clientY) {
			x = ev.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
			y = ev.clientY + document.body.scrollTop + document.documentElement.scrollTop;
			}
		// <<< http://www.quirksmode.org/js/events_properties.html#position
		x -= canvas.offsetLeft;
		y -= canvas.offsetTop;
		cellid = this.cellIdFromPoint(x,y);
		return cellid;
	},
		

	cellIdFromPoint: function(x, y) {
		// We build the treemap on-demand
		if (this.treemap === null) {
			this.treemap = this.buildTreemap();
			}
		// Get the Voronoi cells from the tree map given x,y
		var items = this.treemap.retrieve({x:x,y:y}),
			iItem = items.length,
			cells = this.diagram.cells,
			cell, cellid;
		while (iItem--) {
			cellid = items[iItem].cellid;
			cell = cells[cellid];
			if (cell.pointIntersection(x,y) > 0) {
				return cellid;
				}
			}
		return undefined;
		},

	renderCell: function(id, fillStyle, strokeStyle) {
		if (id === undefined) {return;}
		if (!this.diagram) {return;}
		var cell = this.diagram.cells[id];
		if (!cell) {return;}
		var ctx = this.canvas.getContext('2d');
		ctx.globalAlpha = 1;
		// edges
		ctx.beginPath();
		var halfedges = cell.halfedges,
			nHalfedges = halfedges.length,
			v = halfedges[0].getStartpoint();
		ctx.moveTo(v.x,v.y);
		for (var iHalfedge=0; iHalfedge<nHalfedges; iHalfedge++) {
			v = halfedges[iHalfedge].getEndpoint();
			ctx.lineTo(v.x,v.y);
			}
		
		if(fillStyle !== undefined) {
			ctx.fillStyle = fillStyle;
			ctx.fill();
		}
		
		// ctx.strokeStyle = strokeStyle;
		// ctx.stroke();
		// site
		// v = cell.site;
		// ctx.fillStyle = '#44f';
		// ctx.beginPath();
		// ctx.rect(v.x-2/3,v.y-2/3,2,2);
		// ctx.fill();
		},
		
	addKsites: function (k) {
		this.randomSites(k, false);
		this.render();
		this.drawCells();
	},
	
	loadLinkData: function () {
        links = [
            {"name": "Shtetl-Optimized", "link": "http://www.scottaaronson.com/blog/"},
            {"name": "Chris Done", "link": "http://www.chrisdone.com"},
            {"name": "Thomas Vidick", "link": "http://mycqstate.wordpress.com/"},
            {"name": "Quantum Frontiers", "link": "http://quantumfrontiers.com/"},
            {"name": "The Quantum Pontiff", "link": "http://dabacon.org/pontiff"},
            {"name": "Edwin Brady", "link": "http://edwinb.wordpress.com/blog/"},
            {"name": "A Neighborhood of Infinity", "link": "http://blog.sigfpe.com/"},
            {"name": "Haskell for all", "link": "http://www.haskellforall.com/"},
            {"name": "thi.ng", "link": "http://thi.ng/"},
            {"name": "bit-player", "link": "http://bit-player.org/"},
            {"name": "run hello", "link": "http://msm.runhello.com/"},
            {"name": "Edward Kmett Tutorials", "link": "https://www.fpcomplete.com/user/edwardk"},
            {"name": "Rufflewind", "link": "https://rufflewind.com/"},
            {"name": "Bows and Arrows", "link": "http://sordina.github.io/"},
            {"name": "Paul Chiusano", "link": "https://pchiusano.github.io/"},
            {"name": "Roman Cheplyaka", "link": "https://ro-che.info/"},
            {"name": "Spiros Eliopoulos", "link": "http://computationallyendowed.com/"},
            {"name": "Mike McQuaid", "link": "http://mikemcquaid.com/"},
            {"name": "Rachel by the bay", "link": "http://rachelbythebay.com/w/"},
            {"name": "Simon Marlow", "link": "http://simonmar.github.io/"},
            {"name": "Brad Knox", "link": "http://www.bradknox.net/"},
            {"name": "Polyfractal", "link": "https://polyfractal.com/"},
            {"name": "Be Like Water", "link": "https://belikewater.blog"},
            {"name": "Deborah Schmidt", "link": "http://frauzufall.de/en/"},
            {"name": "Algorithmic Assertions", "link": "http://algorithmicassertions.com"},
            {"name": "Matt Fraser", "link": "https://mattfraser.co.nz/"},
            {"name": "Galaxy Kate", "link": "http://www.galaxykate.com/"},
            {"name": "Jeni's Musing", "link": "http://www.jenitennison.com/archive/index.html"},
            ]

        VoronoiLinks.updateData(links);
	},
	
	render: function() {
		var ctx = this.canvas.getContext('2d');
		// background
		ctx.globalAlpha = 1;
		ctx.beginPath();
		ctx.rect(0,0,this.canvas.width,this.canvas.height);
		ctx.fillStyle = 'white';
		ctx.fill();
		ctx.strokeStyle = '#888';
		ctx.stroke();
		// voronoi
		if (!this.diagram) {return;}
		// edges
		ctx.beginPath();
		ctx.strokeStyle = '#000';
		var edges = this.diagram.edges,
			iEdge = edges.length,
			edge, v;
		while (iEdge--) {
			edge = edges[iEdge];
			v = edge.va;
			ctx.moveTo(v.x,v.y);
			v = edge.vb;
			ctx.lineTo(v.x,v.y);
			}
		ctx.stroke();
		// sites
		ctx.beginPath();
		ctx.fillStyle = '#44f';
		var sites = this.sites,
			iSite = sites.length;
		while (iSite--) {
			v = sites[iSite];
			ctx.rect(v.x-2/3,v.y-2/3,2,2);
			}
		ctx.fill();
		this.drawCells();
		},
};

