class Next extends Backbone.View
    initialize: ->
        App.results.on 'change', @render

    render: =>
        if App.results.get('start') > 0
            @$el.html $('#next-tpl').html()
        else
            @$el.html ""

    events:
        'click': ->
            App.query.next() if App.results.get('start') > 0
            App.results.build_results App.query.get('q'), App.query.get('page')
