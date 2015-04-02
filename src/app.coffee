App =
    query: new Query q: "*"
    results: new Results
    stats: new Stats
    selected: new Backbone.Model
    preview: new Backbone.Model
    categories: new Categories

$(->
    new QueryForm el: 'header'
    #new Message el: '#message'
    new Timeline el: '#timeline'
    new Summary el: '#summary'
    new Modal el: '#selected'
    new Prev el: '#prev'
    new Next el: '#next'

    App.categories.fetch
        success: ->
            App.results.build_results App.query.get('q'), App.query.get('page')
            App.stats.build_summary App.query.get('q')
)
