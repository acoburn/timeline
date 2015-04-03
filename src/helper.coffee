# Helper functions
App = (App || {})

solr_query_uri = (params) ->
    p = jQuery.param(_.defaults params, Config.search_params)
    "#{Config.solr}#{p}"

MONTHS = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December" ]

format_date_range = (start, end) ->
    s = new Date(start)
    e = new Date(end)

    formatted = "#{MONTHS[s.getUTCMonth()]} #{s.getUTCDate()}"
    if e.getUTCFullYear() is s.getUTCFullYear()
        if e.getUTCMonth() is s.getUTCMonth()
            if e.getUTCDate() is s.getUTCDate()
                formatted += ", #{s.getUTCFullYear()}"
            else
                formatted += " - #{e.getUTCDate()}, #{s.getUTCFullYear()}"
        else
            formatted += " - #{MONTHS[e.getUTCMonth()]} #{e.getUTCDate()}, #{e.getFullYear()}"
    else
        formatted += ", #{s.getUTCFullYear()} - #{MONTHS[e.getUTCMonth()]} #{e.getUTCDate()}, #{e.getUTCFullYear()}"
    formatted

