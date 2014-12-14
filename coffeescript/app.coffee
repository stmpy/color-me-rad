App = new Marionette.Application
	regions:
		application: '#main'
		tabs: 'dl.tabs'
		content: 'div.content'


##     ##  #######  ########  ######## ##        ######  
###   ### ##     ## ##     ## ##       ##       ##    ## 
#### #### ##     ## ##     ## ##       ##       ##       
## ### ## ##     ## ##     ## ######   ##        ######  
##     ## ##     ## ##     ## ##       ##             ## 
##     ## ##     ## ##     ## ##       ##       ##    ## 
##     ##  #######  ########  ######## ########  ######  


Event = Backbone.Model.extend {}
Events = Backbone.Collection.extend model: Event

Tab = Backbone.Model.extend {}
Tabs = Backbone.Collection.extend model: Tab


##     ## #### ######## ##      ##  ######  
##     ##  ##  ##       ##  ##  ## ##    ## 
##     ##  ##  ##       ##  ##  ## ##       
##     ##  ##  ######   ##  ##  ##  ######  
 ##   ##   ##  ##       ##  ##  ##       ## 
  ## ##    ##  ##       ##  ##  ## ##    ## 
   ###    #### ########  ###  ###   ######  


TabView = Marionette.ItemView.extend
	tagName: 'dd'
	className: ->
		return 'active' if @model.get('href') is Backbone.history.fragment
		''
	template: _.template('<a href="#/<%= href %>"><%= name %></a>')

TabsView = Marionette.CollectionView.extend
	tagName: 'dl'
	className: 'right'
	childView: TabView
	events:
		'click dd': 'changeTab'

	changeTab: (ev,el) -> @$(ev.target).parent().addClass('active').siblings().removeClass('active')

EventView = Marionette.ItemView.extend
	className: 'eventbrite-event'
	template: _.template '
		<strong style="text-transform:uppercase;"><%= venue.address.city %>, <%= venue.address.region %></strong><br/>
		<%= moment(start.local,moment.ISO_8601).format("MM-DD-YY") %> | <a href="#">Sign Up</a>
	'
	# initialize: ->
	# 	console.log @model.attributes

ThirdColumnView = Marionette.CollectionView.extend
	className: 'medium-4 small-6 columns'
	childView: EventView


##          ###    ##    ##  #######  ##     ## ########  ######  
##         ## ##    ##  ##  ##     ## ##     ##    ##    ##    ## 
##        ##   ##    ####   ##     ## ##     ##    ##    ##       
##       ##     ##    ##    ##     ## ##     ##    ##     ######  
##       #########    ##    ##     ## ##     ##    ##          ## 
##       ##     ##    ##    ##     ## ##     ##    ##    ##    ## 
######## ##     ##    ##     #######   #######     ##     ######  

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
	template: _.template("")
	onRender: ->
		self = this
		_.each @getOption('categories'), (group,category) ->
			
			self.$el.prepend "<h4>" + category + "</h4>", (new ColumnLayout column_count: 3, columns: _.groupBy group, (event,i) ->
				(parseInt i / (group.length / 3))).render().el

   ###    ########  ########  
  ## ##   ##     ## ##     ## 
 ##   ##  ##     ## ##     ## 
##     ## ########  ########  
######### ##        ##        
##     ## ##        ##        
##     ## ##        ##        


Controller = Marionette.Controller.extend
	upcoming: ->
		grouped_by_date = App.events['by_date'].groupBy (ev,i) -> moment(ev.get('start').local).format("MMMM YYYY")
		App.content.show new CategoryLayout categories: grouped_by_date

	alphabetical: ->
		grouped_by_city = App.events['by_date'].groupBy (ev,i) -> ev.get('venue').address.city.substr(0,1)
		App.content.show new CategoryLayout categories: grouped_by_city

	nearby: ->
		@_show 'by_proximity'

	_show: (list) ->
		App.content.show new ColumnLayout column_count: 3, columns: App.events[list].groupBy (event,i) ->
			(parseInt i / (App.events[list].length / 3))

Router = Marionette.AppRouter.extend
	appRoutes:
		'upcoming(/)': 'upcoming'
		'alphabetical(/)': 'alphabetical'
		'nearby(/)': 'nearby'

App.addInitializer (events) ->

	# Create collection of events
	# DEBUG -- START
	# grow the list of events by a LOT
	_.times 4, ->
		events = _.each events, (event) ->
			events.push(event)
	# DEBUG -- END

	@events =
		by_date: new Events _.sortBy events, (ev) -> ev.start.local
		by_city: new Events _.sortBy events, (ev) -> -ev.venue.address.city.substr(0,1)
		by_proxity: new Events _.sortBy events, 'venue.address.latitude'

	@router = new Router
		controller: new Controller

	# start navigation
	Backbone.history.start()

	if Backbone.history.fragment is ""
		@router.navigate "#/upcoming"

	# Add navigation
	@tabs.show new TabsView
		collection: new Tabs [
			href: 'upcoming'
			name: 'Upcoming'
		,
			href: 'alphabetical'
			name: 'Alphabetical'
		,
			href: 'nearby'
			name: 'Nearby'
		]
