class Categories extends Backbone.Collection

    model: Backbone.Model

    parse: (data) ->
        c = data.facet_counts.facet_fields.category.filter (_x, i) -> i % 2 is 0
        c.map (x) ->
            catagory: x

    url: solr_query_uri
            q: '*'
            rows: 0
            facet: true
            "facet.field": "category"
            "facet.mincount": 1
