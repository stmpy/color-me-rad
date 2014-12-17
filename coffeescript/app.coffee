App = new Marionette.Application
	regions:
		application: '.main-content'


# ##     ##  #######  ########  ######## ##        ######  
# ###   ### ##     ## ##     ## ##       ##       ##    ## 
# #### #### ##     ## ##     ## ##       ##       ##       
# ## ### ## ##     ## ##     ## ######   ##        ######  
# ##     ## ##     ## ##     ## ##       ##             ## 
# ##     ## ##     ## ##     ## ##       ##       ##    ## 
# ##     ##  #######  ########  ######## ########  ######  


Event = Backbone.Model.extend {}
Events = Backbone.Collection.extend model: Event

Tab = Backbone.Model.extend {}
Tabs = Backbone.Collection.extend model: Tab


# ##     ## #### ######## ##      ##  ######  
# ##     ##  ##  ##       ##  ##  ## ##    ## 
# ##     ##  ##  ##       ##  ##  ## ##       
# ##     ##  ##  ######   ##  ##  ##  ######  
#  ##   ##   ##  ##       ##  ##  ##       ## 
#   ## ##    ##  ##       ##  ##  ## ##    ## 
#    ###    #### ########  ###  ###   ######  


TabView = Marionette.ItemView.extend {}

TabsView = Marionette.CollectionView.extend
	events:
		'click li > a': 'ohHell'
	ohHell: (event) ->
		console.log (@collection.findWhere { tab_id: @$(event.currentTarget).attr('href') } ).attributes
	initialize: ->
		self = this
		console.log @el
		@$el.find('li > a').each (i,el) ->
			(self.collection.findWhere { name: self.$(el).html() }).set 'tab_id', self.$(el).attr('href')
		@collection.each (tab) ->
			console.log tab.attributes
	# childViewOptions: (child) ->


EventView = Marionette.ItemView.extend
	className: 'eventbrite-event'
	template: _.template '
		<strong style="text-transform:uppercase;"><%= venue.address.city %>, <%= venue.address.region %></strong><br/>
		<%= moment(start.local,moment.ISO_8601).format("MM-DD-YY") %> | <a href="?event_id=<%= ID %>">Sign Up</a>
	'
	# initialize: ->
	# 	console.log @model.attributes

ThirdColumnView = Marionette.CollectionView.extend
	className: 'medium-4 small-6 columns'
	childView: EventView


# ##          ###    ##    ##  #######  ##     ## ########  ######  
# ##         ## ##    ##  ##  ##     ## ##     ##    ##    ##    ## 
# ##        ##   ##    ####   ##     ## ##     ##    ##    ##       
# ##       ##     ##    ##    ##     ## ##     ##    ##     ######  
# ##       #########    ##    ##     ## ##     ##    ##          ## 
# ##       ##     ##    ##    ##     ## ##     ##    ##    ##    ## 
# ######## ##     ##    ##     #######   #######     ##     ######  

ColumnLayout = Marionette.LayoutView.extend
	className: 'row'
	regions:
		column1: '#column1'
		column2: '#column2'
		column3: '#column3'
	template: _.template('')

	_mapping:
		'3': ThirdColumnView

	onRender: ->
		self = this
		columnView = @_mapping[@getOption('column_count')]
		_.each @getOption('columns'), (group,i) ->
			self.$el.append (new columnView
				collection: new Events group).render().el

CategoryLayout = Marionette.LayoutView.extend
	template: _.template ''
	onRender: ->
		self = this
		_.each @getOption('categories'), (group,category) ->
			
			self.$el.prepend "<div class='row'><div class='large-12 columns'>" + category + "</div></div>", (new ColumnLayout column_count: 3, columns: _.groupBy group, (event,i) ->
				(parseInt i / (group.length / 3))).render().el

MapLayout = Marionette.LayoutView.extend
	template: _.template '<div id="map-canvas" class="google-map-large large-12 columns"></div>'
	className: 'map-layout row'
	markers: []

	onRender: ->

		self = this
		styles = [
			stylers: [ { hue: "#dfecf1" }, { saturation: 40 } ]
		,
			featureType: "road",
			elementType: "geometry",
			stylers: [ { lightness: 100 }, { visibility: "simplified" } ]
		,
			featureType: "road",
			elementType: "labels",
			stylers: [ { visibility: "off" } ]
		]

		if _.isUndefined(@map)
			styledMap = new google.maps.StyledMapType styles, { name: "color me rad" }
			console.log @$('#map-canvas').attr('height')
			@map = new google.maps.Map @$('#map-canvas')[0],
				zoom: 4
				center: new google.maps.LatLng(37.09024, -95.712891);
				mapTypeControlOptions:
					mapTypeIds: [ google.maps.MapTypeId.ROADMAP, 'map_style']

			@map.mapTypes.set 'map_style', styledMap
			@map.setMapTypeId 'map_style'

		# google.maps.event.trigger(@map, "resize")

		@_geoLocate()

		@getOption('evnts').each (event) ->
			self.drawMarker new google.maps.LatLng parseFloat(event.get('venue').latitude), parseFloat(event.get('venue').longitude)

	drawMarker: (location) ->

		@markers.push new google.maps.Marker
			map: @map
			position: location
			animation: google.maps.Animation.DROP

	# Method 1 Geolocation API
	_geoLocate: ->
		# Get visitor location
		# https://developer.mozilla.org/en-US/docs/Web/API/Geolocation.getCurrentPosition
		unless _.isUndefined(navigator.geolocation.getCurrentPosition)
			self = this
			navigator.geolocation.getCurrentPosition (position) ->
				self._setMyLocation position.coords.latitude, position.coords.longitude
			, (error) -> self._ipLocate()

	# Method 2 IP lookup
	_ipLocate: ->
		# https://ipinfo.io
		jQuery.ajax "http://ipinfo.io", 
			context: this
			success: (location) ->
				lat_lng = location.loc.split(',')
				@_setMyLocation parseFloat(lat_lng[0]), parseFloat(lat_lng[1])
			dataType: "jsonp"

	_setMyLocation: (lat,lng) ->
		myLocation = new google.maps.LatLng parseFloat(lat), parseFloat(lng)
		@map.setCenter myLocation
		@map.setZoom 8
		# @drawMarker myLocation

#    ###    ########  ########
#   ## ##   ##     ## ##     ##
#  ##   ##  ##     ## ##     ##
# ##     ## ########  ########
# ######### ##        ##
# ##     ## ##        ##
# ##     ## ##        ##


Controller = Marionette.Controller.extend
	upcoming: ->
		grouped_byDate = App.events['byDate'].groupBy (ev,i) -> moment(ev.get('start').local).format("MMMM YYYY")
		# App.content.show new CategoryLayout categories: grouped_byDate

	alphabetical: ->
		grouped_byCity = App.events['byDate'].groupBy (ev,i) -> ev.get('venue').address.city.substr(0,1)
		# App.content.show new CategoryLayout categories: grouped_byCity

	nearby: ->
		# App.content.show new MapLayout evnts: App.events['noSort']

Router = Marionette.AppRouter.extend
	appRoutes:
		'upcoming(/)': 'upcoming'
		'alphabetical(/)': 'alphabetical'
		'nearby(/)': 'nearby'

App.addInitializer (events) ->

	# Create collection of events
	# DEBUG -- START
	# grow the list of events by a LOT
	# _.times 4, ->
	# 	events = _.each events, (event) ->
	# 		events.push(event)
	# DEBUG -- END
	
	# console.log events

	@events =
		byDate: new Events _.sortBy events, (ev) -> ev.start.local
		byCity: new Events _.sortBy events, (ev) -> -ev.venue.address.city.substr(0,1)
		noSort: new Events events

	@router = new Router
		controller: new Controller

	# start navigation
	Backbone.history.start()

	if Backbone.history.fragment is ""
		@router.navigate "#/upcoming"

	# Add navigation
	new TabsView
		el: '.ui-tabs-nav'
		collection: new Tabs [
			name: 'Upcoming'
			tab: '#upcoming-tab'
		,
			name: 'Alphabetical'
			tab: '#alphabetical-tab'
		,
			name: 'Nearby'
			tab: '#nearby-tab'
		]
