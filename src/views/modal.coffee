class Modal extends Backbone.View
    initialize: ->
        App.selected.on 'change', @render

    render: =>
        if App.selected.get 'id'
            console.log App.selected.toJSON()

            data = App.selected.toJSON()
            data.date_string = format_date_range data.start, data.end
            data.locations = _.zip(data.municipality, data.country, data.region).map (x) ->
                _.compact(x).join ', '
            data.sources = _.zip(data.source_citation, data.source_title, data.source_url).map (x) ->
                citation: x[0] || x[1]
                title: x[1]
                url: x[2]
            
            @$el.html Mustache.render $('#selected-modal-tpl').html(), data
            
            @$('.modal').modal
                show: true
                backdrop: true
        else
            @$el.html ''

    events:
        'hidden.bs.modal .modal': ->
            App.selected.clear()
 
