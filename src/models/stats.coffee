class Stats extends Backbone.Model
    build_summary: (q) ->
        $.get solr_query_uri(q: q, rows: 0, facet: true, "facet.field": "year", "facet.mincount": 1), (data) =>
            years = data.facet_counts.facet_fields.year.map (x) -> parseInt x, 10
            @.set
                data: _.zip.apply null, _.partition years, (_x, i) -> i % 2 == 0

