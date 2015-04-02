class Summary extends Backbone.View
    initialize: ->
        App.results.on 'change:extent', @render
        App.stats.on 'change', @render
        $(window).resize(_.debounce @render, 300)

    render: =>
        if App.stats.get 'data'
            max_h = 15
            data = App.stats.get('data').map (a) ->
                    date: new Date a[0], 1
                    value: a[1]

            @$el.html '<svg></svg>'
            svg = d3.select @$el.find('svg')[0]

            h = @$el.height() - 25
            x = d3.time.scale()
                    .domain([
                        d3.min(data.map (a) -> new Date a.date.getUTCFullYear(), a.date.getUTCMonth() - 1, a.date.getUTCDate()),
                        d3.max(data.map (a) -> new Date a.date.getUTCFullYear(), a.date.getUTCMonth() + 1, a.date.getUTCDate())
                    ])
                    .range([20, @$el.width() - 20])

            y = d3.scale.linear()
                    .domain([0, d3.max data.map (a) -> a.value])
                    .range([h, 0])

            # context data
            context = svg.append("g")
                    .attr("class", "context")

            # lines
            r = d3.scale.linear()
                .domain([1, d3.max data.map (a) -> a.value])
                .range([2, max_h])

            context.selectAll("rect")
                .data(data.filter (a) -> a.value > 0)
                .enter()
                .append("rect")
                .attr("transform", "translate(0, 10)")
                .attr("x", (d) -> -1 + x d.date)
                .attr("width", 2)
                .attr("y", (d) -> h / 2 - r d.value)
                .attr("height", (d) -> 2 * r d.value)


            # context axis
            axis = d3.svg.axis().scale(x).orient("bottom")

            context.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0, #{h})")
                .call(axis)


            if App.results.is_proper_subset()
                padding = 6
                min = App.results.get('extent')[0]
                max = App.results.get('extent')[1]
                context.append("g")
                    .attr("class", "x brush")
                    .append("rect")
                    .attr("transform", "translate(0, #{h / 2 - max_h})")
                    .attr("y", 0)
                    .attr("height", max_h * 2 + 20)
                    .attr("x", x(min) - 5)
                    .attr("width", x(max) - x(min) + 10)
                


