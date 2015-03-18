App = App || {}

# Models
class Query extends Backbone.Model
    defaults:
        q: ''
        filters: []
        page: 0
        rows: 20

class Results extends Backbone.Model

# Views
class QueryForm extends Backbone.View
    events:
        'click .fa-search': ->
            @$('form').submit()

        'submit form': ->
            App.query.set
                q: @$('input').val()
                filters: []
                page: 0
                rows: 20
            @$('input').blur()
            false

class Message extends Backbone.View
    initialize: ->
        App.query.on 'change', @render

    render: =>
        @$el.html(App.query.get 'q')

class Timeline extends Backbone.View
    initialize: ->
        App.results.on 'change', @render

    render: =>
        @$el.html('<svg></svg>')

class Summary extends Backbone.View
    initialize: ->
        App.stats.on 'change', @render
        $(window).resize(_.debounce(@render, 300))

    render: =>
        scale = d3.time.scale()
                  .domain([
                      new Date(App.stats.get('min')),
                      new Date(App.stats.get('max'))])
                  .range([0, @$el.width() - 1])
        
        @$el.html('<svg></svg>')
        d3.select(@$el.find('svg')[0])
           .append('g')
           .attr('class', 'axis')
           .attr('transform', "translate(0, #{@$el.height() - 25})")
           .call(d3.svg.axis()
                    .scale(scale)
                    .orient('bottom'))

#Impl
App.query = new Query
App.results = new Results
App.stats = new Results
$(->
    new QueryForm el: 'header'
    new Message el: '#message'
    new Timeline el: '#timeline'
    new Summary el: '#summary'
    
    $.get solr_query_uri(q: "*", rows: 0), (data) ->
        App.stats.set
           min: data.stats.stats_fields.date.min
           max: data.stats.stats_fields.date.max

    App.results.set('foo', 'bar')
)
