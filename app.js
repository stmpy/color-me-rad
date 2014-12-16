var App, CategoryLayout, ColumnLayout, Controller, Event, EventView, Events, MapLayout, Router, Tab, TabView, Tabs, TabsView, ThirdColumnView;

App = new Marionette.Application({
  regions: {
    application: '#main',
    tabs: 'dl.tabs',
    content: 'div.content'
  }
});

Event = Backbone.Model.extend({});

Events = Backbone.Collection.extend({
  model: Event
});

Tab = Backbone.Model.extend({});

Tabs = Backbone.Collection.extend({
  model: Tab
});

TabView = Marionette.ItemView.extend({
  tagName: 'dd',
  className: function() {
    if (this.model.get('href') === Backbone.history.fragment) {
      return 'active';
    }
    return '';
  },
  template: _.template('<a href="#/<%= href %>"><%= name %></a>')
});

TabsView = Marionette.CollectionView.extend({
  tagName: 'dl',
  className: 'right',
  childView: TabView,
  events: {
    'click dd': 'changeTab'
  },
  changeTab: function(ev, el) {
    return this.$(ev.target).parent().addClass('active').siblings().removeClass('active');
  }
});

EventView = Marionette.ItemView.extend({
  className: 'eventbrite-event',
  template: _.template('<strong style="text-transform:uppercase;"><%= venue.address.city %>, <%= venue.address.region %></strong><br/> <%= moment(start.local,moment.ISO_8601).format("MM-DD-YY") %> | <a href="?event_id=<%= ID %>">Sign Up</a>')
});

ThirdColumnView = Marionette.CollectionView.extend({
  className: 'medium-4 small-6 columns',
  childView: EventView
});

ColumnLayout = Marionette.LayoutView.extend({
  className: 'row',
  regions: {
    column1: '#column1',
    column2: '#column2',
    column3: '#column3'
  },
  template: _.template(''),
  _mapping: {
    '3': ThirdColumnView
  },
  onRender: function() {
    var columnView, self;
    self = this;
    columnView = this._mapping[this.getOption('column_count')];
    return _.each(this.getOption('columns'), function(group, i) {
      return self.$el.append((new columnView({
        collection: new Events(group)
      })).render().el);
    });
  }
});

CategoryLayout = Marionette.LayoutView.extend({
  template: _.template(''),
  onRender: function() {
    var self;
    self = this;
    return _.each(this.getOption('categories'), function(group, category) {
      return self.$el.prepend("<div class='row'><div class='large-12 columns'>" + category + "</div></div>", (new ColumnLayout({
        column_count: 3,
        columns: _.groupBy(group, function(event, i) {
          return parseInt(i / (group.length / 3));
        })
      })).render().el);
    });
  }
});

MapLayout = Marionette.LayoutView.extend({
  template: _.template('<div id="map-canvas" class="google-map-large large-12 columns"></div>'),
  className: 'map-layout row',
  markers: [],
  onRender: function() {
    var self, styledMap, styles;
    self = this;
    styles = [
      {
        stylers: [
          {
            hue: "#dfecf1"
          }, {
            saturation: 40
          }
        ]
      }, {
        featureType: "road",
        elementType: "geometry",
        stylers: [
          {
            lightness: 100
          }, {
            visibility: "simplified"
          }
        ]
      }, {
        featureType: "road",
        elementType: "labels",
        stylers: [
          {
            visibility: "off"
          }
        ]
      }
    ];
    if (_.isUndefined(this.map)) {
      styledMap = new google.maps.StyledMapType(styles, {
        name: "color me rad"
      });
      console.log(this.$('#map-canvas').attr('height'));
      this.map = new google.maps.Map(this.$('#map-canvas')[0], {
        zoom: 4,
        center: new google.maps.LatLng(37.09024, -95.712891),
        mapTypeControlOptions: {
          mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'map_style']
        }
      });
      this.map.mapTypes.set('map_style', styledMap);
      this.map.setMapTypeId('map_style');
    }
    this._geoLocate();
    return this.getOption('evnts').each(function(event) {
      return self.drawMarker(new google.maps.LatLng(parseFloat(event.get('venue').latitude), parseFloat(event.get('venue').longitude)));
    });
  },
  drawMarker: function(location) {
    return this.markers.push(new google.maps.Marker({
      map: this.map,
      position: location,
      animation: google.maps.Animation.DROP
    }));
  },
  _geoLocate: function() {
    var self;
    if (!_.isUndefined(navigator.geolocation.getCurrentPosition)) {
      self = this;
      return navigator.geolocation.getCurrentPosition(function(position) {
        return self._setMyLocation(position.coords.latitude, position.coords.longitude);
      }, function(error) {
        return self._ipLocate();
      });
    }
  },
  _ipLocate: function() {
    return jQuery.ajax("http://ipinfo.io", {
      context: this,
      success: function(location) {
        var lat_lng;
        lat_lng = location.loc.split(',');
        return this._setMyLocation(parseFloat(lat_lng[0]), parseFloat(lat_lng[1]));
      },
      dataType: "jsonp"
    });
  },
  _setMyLocation: function(lat, lng) {
    var myLocation;
    myLocation = new google.maps.LatLng(parseFloat(lat), parseFloat(lng));
    this.map.setCenter(myLocation);
    return this.map.setZoom(8);
  }
});

Controller = Marionette.Controller.extend({
  upcoming: function() {
    var grouped_byDate;
    grouped_byDate = App.events['byDate'].groupBy(function(ev, i) {
      return moment(ev.get('start').local).format("MMMM YYYY");
    });
    return App.content.show(new CategoryLayout({
      categories: grouped_byDate
    }));
  },
  alphabetical: function() {
    var grouped_byCity;
    grouped_byCity = App.events['byDate'].groupBy(function(ev, i) {
      return ev.get('venue').address.city.substr(0, 1);
    });
    return App.content.show(new CategoryLayout({
      categories: grouped_byCity
    }));
  },
  nearby: function() {
    return App.content.show(new MapLayout({
      evnts: App.events['noSort']
    }));
  }
});

Router = Marionette.AppRouter.extend({
  appRoutes: {
    'upcoming(/)': 'upcoming',
    'alphabetical(/)': 'alphabetical',
    'nearby(/)': 'nearby'
  }
});

App.addInitializer(function(events) {
  console.log(events);
  this.events = {
    byDate: new Events(_.sortBy(events, function(ev) {
      return ev.start.local;
    })),
    byCity: new Events(_.sortBy(events, function(ev) {
      return -ev.venue.address.city.substr(0, 1);
    })),
    noSort: new Events(events)
  };
  this.router = new Router({
    controller: new Controller
  });
  Backbone.history.start();
  if (Backbone.history.fragment === "") {
    this.router.navigate("#/upcoming");
  }
  return this.tabs.show(new TabsView({
    collection: new Tabs([
      {
        href: 'upcoming',
        name: 'Upcoming'
      }, {
        href: 'alphabetical',
        name: 'Alphabetical'
      }, {
        href: 'nearby',
        name: 'Nearby'
      }
    ])
  }));
});
