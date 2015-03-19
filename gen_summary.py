import requests
import logging
import json
import dateutil.parser
import datetime

SOLR = "http://127.0.0.1:8983/solr/lgbt/select?"

def get_stats():
    res = requests.get(SOLR + "wt=json&rows=0&q=*&stats=true&stats.field=date")
    if res.status_code == 200:
        return res.json()["stats"]["stats_fields"]["date"]
    else:
        logging.error("Bad Response: {0}".format(res.status_code))

def get_year_count(year):
    res = requests.get(SOLR + "wt=json&rows=0&q=year:{0}".format(year))
    if res.status_code == 200:
        return res.json()["response"]["numFound"]
    else:
        logging.error("Bad Response: {0}".format(res.status_code))


if __name__ == "__main__":

    logging.basicConfig(level=logging.INFO)
    logging.getLogger("requests").setLevel(logging.WARNING)
    stats = get_stats()
    
    start = dateutil.parser.parse(stats["min"]).year
    end = dateutil.parser.parse(stats["max"]).year
    
    year_counts = []
   
    for i in range(start, end + 1):
        year_counts.append([i, get_year_count(i)])

    print json.dumps(year_counts)

