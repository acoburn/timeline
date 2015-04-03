class Next extends Backbone.View
    initialize: ->
        App.results.on 'change', @render

    render: =>
        if App.results.get('start') > 0
            @$el.html $('#next-tpl').html()
        else
            @$el.html "<div></div>"

    events:
        'click': ->
            App.query.next() if App.results.get('start') > 0
            App.results.fetch()
