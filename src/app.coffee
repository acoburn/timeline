App = (App || {})

App.query = new Query q: "*"
App.results = new Results
App.stats = new Stats
App.selected = new Backbone.Model
App.preview = new Backbone.Model
App.categories = new Categories

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
            App.results.fetch()
            App.stats.fetch()
)
