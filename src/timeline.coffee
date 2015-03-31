App = App || {}

# Models
class Query extends Backbone.Model
    defaults:
        q: ''
        filters: []
        page: 0
        rows: 20

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
                rows: Config.rows
            @$('input').blur()
            false

class Message extends Backbone.View
    initialize: ->
        App.query.on 'change', @render

    render: =>
        @$el.html(App.query.get 'q')

class Modal extends Backbone.View
    initialize: ->
        App.selected.on 'change', @render

    render: =>
        if App.selected.get 'id'
            console.log App.selected.toJSON()
            data = App.selected.toJSON()
            data.date_string = format_date_range(data.start, data.end)
            data.locations = _.zip(data.municipality, data.country, data.region).map (x) ->
                _.compact(x).join ', '
            data.sources = _.zip(data.source_citation, data.source_title, data.source_url)
            tpl = _.template($('#selected-modal-tpl').html())
            @$el.html(tpl data: data)
            @$('.modal').modal
                show: true
                backdrop: true
        else
            @$el.html ''

    events:
        'hidden.bs.modal .modal': ->
            App.selected.clear()
        
class Timeline extends Backbone.View
    initialize: ->
        App.results.on 'change', @render
        $(window).resize(_.debounce(@render, 300))

    render: =>
        padding = 25
        data = App.results.get('data')

        @$el.html('<svg></svg>')
        
        h = @$el.height() - padding
        epsilon = .75 * h / Config.packing

        x = d3.time.scale()
              .domain(d3.extent(data.map (a) -> a.date))
              .range([padding, @$el.width() - padding])

        y = d3.scale.linear()
              .domain(d3.extent(data.map (a) -> a.pos))
              .range([h - epsilon / 2 - padding, epsilon / 2 + padding])

        # svg element
        svg = d3.select(@$el.find('svg')[0])

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
            .attr("data-title", (d) -> d.title)
            .attr("data-id", (d) -> d.id)
            .attr("transform", "translate(0, 10)")
            .attr("fill", (d) ->
                switch d.progress
                    when "Forwards" then "green"
                    when "Backwards" then "red"
                    else "black")
            .attr("cx", (d) -> x d.date)
            .attr("cy", (d) -> y(d.pos) + d.v % epsilon - epsilon / 2)
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
            App.selected.set App.results.get('index')[id]

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
App.results = new Backbone.Model
App.stats = new Backbone.Model
App.selected = new Backbone.Model
App.preview = new Backbone.Model

$(->
    new QueryForm el: 'header'
    new Message el: '#message'
    new Timeline el: '#timeline'
    new Summary el: '#summary'
    new Modal el: '#selected'

    $.get solr_query_uri(q: "*", rows: Config.rows), (data) ->
        App.results.set
           min: data.stats.stats_fields.start.min
           max: data.stats.stats_fields.start.max
           count: data.response.numFound
           index: _.indexBy data.response.docs, "id"
           data: data.response.docs.map((x, i) ->
                    id: x.id
                    pos: i % Config.packing
                    v: x["_version_"]
                    date: new Date x.start
                    progress: x.progress
                    title: x.title).reverse()

    $.get solr_query_uri(q: "*", rows: 0, facet: true, "facet.field": "year"), (data) ->
        years = data.facet_counts.facet_fields.year.map (x) -> parseInt x, 10
        App.stats.set
            data: _.zip.apply(null, _.partition years, (_x, i) -> i % 2 == 0)

)
