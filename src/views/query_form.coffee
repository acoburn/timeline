class QueryForm extends Backbone.View
    events:
        'click .fa-search': ->
            @$('form').submit()

        'submit form': ->
            q = @$('input').val().trim()
            App.query.set
                q: if q.length then q else '*'
                filters: {}
                page: 0
            @$('input').blur()
            App.results.fetch()
            App.stats.fetch()
            false


