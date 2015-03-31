class Summary extends Backbone.View
    initialize: ->
        App.stats.on 'change', @render
        $(window).resize(_.debounce @render, 300)

    render: =>
        data = App.stats.get('data').map (a) ->
                date: new Date a[0], 1
                value: a[1]

        @$el.html '<svg></svg>'
        svg = d3.select @$el.find('svg')[0]

        h = @$el.height() - 25
        x = d3.time.scale()
                .domain(d3.extent data.map (a) -> a.date)
                .range([20, @$el.width() - 20])

        y = d3.scale.linear()
                .domain([0, d3.max data.map (a) -> a.value])
                .range([h, 0])

        brushed = ->
            x.domain(brush.extent())
            #focus.select(".area").attr("d", area)
            #focus.select(".x.axis").call(xAxis)

        brush = d3.svg.brush()
                .x(x)
                .on("brush", brushed)

        # context data
        context = svg.append("g")
                .attr("class", "context")
        h2 = d3.max(data, (a) -> a.value) + 25
        y2 = d3.scale.linear()
                .domain([0, d3.max data.map (a) -> a.value])
                .range([h2, 0])

        # circles
        r = d3.scale.linear()
            .domain([1, d3.max data.map (a) -> a.value])
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


