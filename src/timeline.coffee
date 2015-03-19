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
        $(window).resize(_.debounce(@render, 300))

    render: =>
        data = App.results.get('data')
        
        @$el.html('<svg></svg>')
        svg = d3.select(@$el.find('svg')[0])

        h = @$el.height() - 25
        x = d3.time.scale()
                .domain(d3.extent(data.map (a) -> new Date a.date))
                .range([20, @$el.width() - 20])
                
        y = d3.scale.linear()
                .domain([0, h])
                .range([h, 0])

        # context data
        context = svg.append("g")
                .attr("class", "context")

        # circles
        r = d3.scale.linear()
            .domain([1, d3.max(data.map (a) -> a.value)])
            .range([2, 15])

        context.selectAll("circle")
            .data(data)
            .enter()
            .append("circle")
            .attr("data-title", (d) -> d.description)
            .attr("data-id", (d) -> d.id)
            .attr("transform", "translate(0, 10)")
            .attr("cx", (d) -> x(new Date d.date))
            .attr("cy", -> Math.floor(Math.random() * (h - 25)))
            .attr("r", 5)

        # context axis
        axis = d3.svg.axis().scale(x).orient("bottom")

        context.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{h})")
            .call(axis)

    events:
        "mouseenter circle": (e) ->
            # disploy popup
            console.log $(e.target).data('title')

        "click circle": (e) ->
            # display full modal
            id = $(e.target).data 'id'
            console.log App.results.get('index')[id]

class Summary extends Backbone.View
    initialize: ->
        App.stats.on 'change', @render
        $(window).resize(_.debounce(@render, 300))

    render: =>
        data = App.stats.get('data').map (a) ->
                date: new Date(a[0], 1)
                value: a[1]

        @$el.html('<svg></svg>')
        svg = d3.select(@$el.find('svg')[0])

        h = @$el.height() - 25
        x = d3.time.scale()
                .domain(d3.extent(data.map (a) -> a.date))
                .range([20, @$el.width() - 20])
                
        y = d3.scale.linear()
                .domain([0, d3.max(data.map (a) -> a.value)])
                .range([h, 0])

        brushed = ->
            x.domain(brush.extent())
        #    focus.select(".area").attr("d", area)
            #focus.select(".x.axis").call(xAxis)
            
        brush = d3.svg.brush()
                .x(x)
                .on("brush", brushed)

        # context data
        context = svg.append("g")
                .attr("class", "context")
        h2 = d3.max(data, (a) -> a.value) + 25
        y2 = d3.scale.linear()
                .domain([0, d3.max(data.map (a) -> a.value)])
                .range([h2, 0])

        # circles
        r = d3.scale.linear()
            .domain([1, d3.max(data.map (a) -> a.value)])
            .range([2, 15])

        context.selectAll("circle")
            .data(data.filter (a) -> a.value > 0)
            .enter()
            .append("circle")
            .attr("transform", "translate(0, #{h-h2})")
            .attr("cx", (d) -> x d.date)
            .attr("cy", 20)
            .attr("r", (d) -> r d.value)

        # context axis
        axis = d3.svg.axis().scale(x).orient("bottom")

        context.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0, #{h})")
            .call(axis)

        context.append("g")
            .attr("class", "x brush")
            .attr("transform", "translate(0, #{h-h2})")
            .call(brush)
          .selectAll("rect")
            .attr("y", -6)
            .attr("height", h2 + 7)


#Impl
App.query = new Query
App.results = new Results
App.stats = new Results

$(->
    new QueryForm el: 'header'
    new Message el: '#message'
    new Timeline el: '#timeline'
    new Summary el: '#summary'
    
    $.get solr_query_uri(q: "*", rows: 30), (data) ->
        App.results.set
           min: data.stats.stats_fields.date.min
           max: data.stats.stats_fields.date.max
           count: data.response.numFound
           data: data.response.docs.map((x) -> id: x.id, date: new Date(x.date), description: x.description).reverse()
           index: _.indexBy(data.response.docs, "id")
           
    $.get 'data/summary.json', (data) ->
        App.stats.set data: data

)
