import requests
import csv
import datetime
import json
import logging

SOLR_UPDATE_URL = "http://127.0.0.1:8983/solr/lgbt/update"

def parse_date(date):
    d = None
    try:
        d = datetime.datetime.strptime(date, '%B %Y')
    except ValueError as ex:
        try:
            d = datetime.datetime.strptime(date, '%b %Y')
        except ValueError as ex:
            try:
                d = datetime.datetime.strptime(date, "%Y")
            except Exception as ex:
                pass
    if d is not None:
        return d.isoformat() + "Z"


def to_solr(id, data):
    text_fields = [
            "modified", "editor", "reviewed", "description", "text",
            "step", "source", "month", "year"]
    
    split_fields = [
            "region", "country", "municipality",
            "keyword", "categories", "people", "relationships" ]
    
    date = parse_date("{0} {1}".format(data["month"], data["year"]).strip())
    if date is not None:
        mydata = {
                "id": id,
                "date": date,
                "media_uri": data['media_type'] + ":" + data['media_source']
                }

        sd = parse_date(data["source_date"])
        if sd is not None:
            mydata["source_date"] = sd
            
        for s in split_fields:
            mydata[s] = [x.strip() for x in data[s].split(',')]

        for t in text_fields:
            mydata[t] = data[t]

        res = requests.post(SOLR_UPDATE_URL, data=json.dumps([mydata]),
                headers={'Content-Type': "application/json"})
        if res.status_code is not 200:
            logging.error("Error on line {0}: {1}".format(id, res.status_code))
    else:
        logging.error("Invalid date on line {0}: {1} {2}".format(id, data["month"], data["year"]))


if __name__ == "__main__":

    logging.basicConfig(level=logging.INFO)
    logging.getLogger("requests").setLevel(logging.WARNING)

    with open('data/lgbt.csv', 'rb') as fp:
        fieldnames = [
                'modified', 'editor', 'reviewed', 'description', 'text', 'keyword',
                'categories', 'year', 'month', 'region', 'country', 'municipality',
                'step', 'people', 'SKIP_1', 'relationships', 'source', 'source_date',
                'media_type', 'media_source']
                       
        reader = csv.DictReader(fp, delimiter=',', fieldnames=fieldnames)
        line = 1;
        for row in reader:
            date = None
            
            if line > 1:
                to_solr(line, row)

            line += 1

        requests.get(SOLR_UPDATE_URL + "?commit=true")
        logging.info("Added {0} documents to solr".format(line - 2))
