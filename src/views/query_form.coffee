class QueryForm extends Backbone.View
    events:
        'click .fa-search': ->
            @$('form').submit()

        'submit form': ->
            App.query.set
                q: @$('input').val()
                filters: []
                page: 0
            @$('input').blur()
            App.results.build_results App.query.get('q'), 0
            App.stats.build_summary App.query.get 'q'
            false


