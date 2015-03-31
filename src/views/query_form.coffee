class QueryForm extends Backbone.View
    events:
        'click .fa-search': ->
            @$('form').submit()

        'submit form': ->
            App.query.set
                q: @$('input').val()
                filters: []
                page: 0
                rows: Config.rows
            @$('input').blur()
            false


