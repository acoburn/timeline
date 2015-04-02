class Summary extends Backbone.View
    initialize: ->
        App.results.on 'change:extent', @render
        App.stats.on 'change', @render
        $(window).resize(_.debounce @render, 300)

    render: =>
        if App.stats.get 'data'
            min_r = 2
            max_r = 15
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

            # context data
            context = svg.append("g")
                    .attr("class", "context")

            # circles
            r = d3.scale.linear()
                .domain([1, d3.max data.map (a) -> a.value])
                .range([min_r, max_r])

            context.selectAll("circle")
                .data(data.filter (a) -> a.value > 0)
                .enter()
                .append("circle")
                .attr("transform", "translate(0, #{h - max_r * 2 - 10})")
                .attr("cx", (d) -> x d.date)
                .attr("cy", max_r + 5)
                .attr("r", (d) -> r d.value)

            # context axis
            axis = d3.svg.axis().scale(x).orient("bottom")

            context.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0, #{h})")
                .call(axis)

            if App.results.get 'extent'
                padding = 6
                min = App.results.get('extent')[0]
                max = App.results.get('extent')[1]
                context.append("g")
                    .attr("class", "x brush")
                    .append("rect")
                    .attr("transform", "translate(0, #{h - max_r * 2 - 10})")
                    .attr("y", 0)
                    .attr("height", max_r * 2 + 9)
                    .attr("x", x(min) - max_r)
                    .attr("width", x(max) - x(min) + max_r * 2)
                


