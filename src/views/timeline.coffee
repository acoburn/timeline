class Timeline extends Backbone.View
    initialize: ->
        App.results.on 'change', @render
        $(window).resize(_.debounce @render, 300)

    render: =>
        padding = 25
        data = App.results.get 'data'

        @$el.html '<svg></svg>'
        
        if data.length
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

            # tool tip
            tip = d3.tip()
                    .attr('class', 'tooltip')
                    .offset([-10, 0])
                    .html( (d) -> d.title)

            svg.call tip

            # categories
            categories = d3.scale.ordinal()
                            .domain(App.categories.toJSON().map (x) -> x.category)
                            .range(_.range(App.categories.length))

            # colors
            colors = d3.scale.linear().domain([0, App.categories.length])
                            .range(["orange", "blue"])

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
                    if d.category then colors categories d.category else "black")
                .attr("cx", (d) -> x d.date)
                .attr("cy", (d) -> y(d.pos) + d.v % epsilon - epsilon / 2)
                .attr("r", 6)
                .on('mouseover', tip.show)
                .on('mouseout', tip.hide)
                .on('click', tip.hide)

            # context axis
            axis = d3.svg.axis().scale(x).orient("bottom")

            context.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0, #{h})")
                .call(axis)

    events:
        "click circle": (e) ->
            App.selected.set App.results.get('index')[$(e.target).data 'id']

