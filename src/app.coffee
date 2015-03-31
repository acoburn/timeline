#Impl
App = {}
App.query = new Query
App.results = new Backbone.Model
App.stats = new Backbone.Model
App.selected = new Backbone.Model
App.preview = new Backbone.Model

$(->
    new QueryForm el: 'header'
    new Message el: '#message'
    new Timeline el: '#timeline'
    new Summary el: '#summary'
    new Modal el: '#selected'

    $.get solr_query_uri(q: "*", rows: Config.rows), (data) ->
        App.results.set
           min: data.stats.stats_fields.start.min
           max: data.stats.stats_fields.start.max
           count: data.response.numFound
           index: _.indexBy data.response.docs, "id"
           data: data.response.docs.map((x, i) ->
                    id: x.id
                    pos: i % Config.packing
                    v: x["_version_"]
                    date: new Date x.start
                    progress: x.progress
                    title: x.title).reverse()

    $.get solr_query_uri(q: "*", rows: 0, facet: true, "facet.field": "year"), (data) ->
        years = data.facet_counts.facet_fields.year.map (x) -> parseInt x, 10
        App.stats.set
            data: _.zip.apply null, _.partition years, (_x, i) -> i % 2 == 0

)
