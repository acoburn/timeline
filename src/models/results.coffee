class Results extends Backbone.Model
    offset: ->
        @.get('data').length + @.get 'start'

    is_proper_subset: ->
        ex = @.get 'extent'
        if ex
            iso = ex.map (x) -> x.toISOString()
            if iso[0] is @.get('min').toISOString() and iso[1] is @.get('max').toISOString()
                false
            else
                true
        else
            false

    parse: (data) ->
        if data.response.numFound
           min: new Date data.stats.stats_fields.start.min
           max: new Date data.stats.stats_fields.start.max
           start: data.response.start
           count: data.response.numFound
           index: _.indexBy data.response.docs, "id"
           extent: d3.extent data.response.docs.map (x) -> new Date x.start
           data: data.response.docs.map((x, i) ->
                    id: x.id
                    pos: i
                    v: x["_version_"]
                    date: new Date x.start
                    progress: x.progress
                    category: _.head x.category
                    title: x.title).reverse()
        else
            min: null
            max: null
            start: 0
            count: 0
            index: {}
            data: []
            extent: null

    urlRoot: ->
        solr_query_uri
            q: App.query.get('q') || "*"
            start: App.query.get('page') * Config.rows
            rows: Config.rows
