Config =
    solr: "/solr/lgbt/select?"
    search_params:
        wt: "json"
        sort: "start desc"
        stats: "true"
        "stats.field": "start"
    packing: 4
    rows: 30
