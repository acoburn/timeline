class Stats extends Backbone.Model
    urlRoot: ->
        solr_query_uri
            q: App.query.get('q') || "*"
            rows: 0
            facet: true
            "facet.field": "year"
            "facet.mincount": 1

    parse: (data) ->
        years = data.facet_counts.facet_fields.year.map (x) -> parseInt x, 10
        data: _.zip.apply null, _.partition years, (_x, i) -> i % 2 == 0
