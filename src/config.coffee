Config =
    solr: "/solr/lgbt/select?"
    search_params:
        wt: "json"
        sort: "date desc"
        stats: "true"
        "stats.field": "date"
