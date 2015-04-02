class QueryForm extends Backbone.View
    events:
        'click .fa-search': ->
            @$('form').submit()

        'submit form': ->
            q = @$('input').val().trim()
            App.query.set
                q: if q.length then q else '*'
                filters: []
                page: 0
            @$('input').blur()
            App.results.build_results App.query.get('q'), 0
            App.stats.build_summary App.query.get 'q'
            false


