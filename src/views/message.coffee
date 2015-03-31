class Message extends Backbone.View
    initialize: ->
        App.query.on 'change', @render

    render: =>
        @$el.html App.query.get 'q'


