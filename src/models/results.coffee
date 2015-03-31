class Results extends Backbone.Model
    offset: ->
        @.get('data').length + @.get 'start'

    build_results: (q, page) ->
        $.get solr_query_uri(q: q, start: page * Config.rows, rows: Config.rows), (data) =>
            @.set
               min: data.stats.stats_fields.start.min
               max: data.stats.stats_fields.start.max
               start: data.response.start
               count: data.response.numFound
               index: _.indexBy data.response.docs, "id"
               data: data.response.docs.map((x, i) ->
                        id: x.id
                        pos: i % Config.packing
                        v: x["_version_"]
                        date: new Date x.start
                        progress: x.progress
                        title: x.title).reverse()


