class Prev extends Backbone.View
    initialize: ->
        App.results.on 'change', @render

    render: =>
        if App.results.offset() < App.results.get 'count'
            @$el.html $('#prev-tpl').html()
        else
            @$el.html "<div></div>"

    events:
        'click': ->
            App.query.prev() if App.results.offset() < App.results.get 'count'
            App.results.fetch()
