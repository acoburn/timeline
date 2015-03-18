# Helper functions
solr_query_uri = (params) ->
    p = jQuery.param(_.defaults params, Config.search_params)
    "#{Config.solr}#{p}"


