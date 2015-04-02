class Timeline extends Backbone.View
    initialize: ->
        App.results.on 'change', @render
        $(window).resize(_.debounce @render, 300)

    render: =>
        padding = 25
        data = App.results.get 'data'

        @$el.html '<svg></svg>'
        
        h = @$el.height() - padding
        epsilon = .75 * h / Config.packing

        x = d3.time.scale()
            .domain([
                d3.min(data.map (a) -> new Date a.date.getUTCFullYear(), a.date.getUTCMonth() - 1, a.date.getUTCDate()),
                d3.max(data.map (a) -> new Date a.date.getUTCFullYear(), a.date.getUTCMonth() + 1, a.date.getUTCDate())
            ])
            .range([padding, @$el.width() - padding])

        y = d3.scale.linear()
              .domain(d3.extent data.map (a) -> a.pos)
              .range([h - epsilon / 2 - padding, epsilon / 2 + padding])

        # svg element
        svg = d3.select @$el.find('svg')[0]

        # context data
        context = svg.append("g")
            .attr("class", "context")

        # circles
        r = d3.scale.linear()
            .domain([1, d3.max data.map (a) -> a.value])
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
            App.selected.set App.results.get('index')[$(e.target).data 'id']

