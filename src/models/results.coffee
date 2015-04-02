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


    build_results: (q, page) ->
        $.get solr_query_uri(q: q, start: page * Config.rows, rows: Config.rows), (data) =>
            if data.response.numFound
                @.set
                   min: new Date data.stats.stats_fields.start.min
                   max: new Date data.stats.stats_fields.start.max
                   start: data.response.start
                   count: data.response.numFound
                   index: _.indexBy data.response.docs, "id"
                   extent: d3.extent data.response.docs.map (x) -> new Date x.start
                   data: data.response.docs.map((x, i) ->
                            id: x.id
                            pos: i % Config.packing
                            v: x["_version_"]
                            date: new Date x.start
                            progress: x.progress
                            title: x.title).reverse()
            else
                @.set
                    min: null
                    max: null
                    start: 0
                    count: 0
                    index: {}
                    data: []
                    extent: null



