import requests
import csv
import datetime
import json
import logging

SOLR_UPDATE_URL = "http://127.0.0.1:8983/solr/lgbt/update"

def parse_date(date):
    d = None
    formats = ["%Y-%m", "%Y-%M", "%Y", "%M/%D/%Y", "%Y-%m-%d"]
    for f in formats:
        if d is None:
            try:
                d = datetime.datetime.strptime(date, f)
            except ValueError as ex:
                pass
    if d is not None:
        return d.isoformat() + "Z"
        
    

def to_solr(id, data):
    text_fields = [
            "modified", "contributor", "reviewer", "title", "description",
            "progress", "text", "symbol", "legislation",
            "media_title", "media_credit", "media_credit", "media_caption"]

    
    split_fields = [
            "region", "country", "municipality",
            "organization", 
            "keyword", "category", "people", "related" ]
    
    split_fields2 = [
            "source_title", "source_author", "source_url", "source_citation" ]

    start = parse_date(data["start"].strip())
    end = parse_date(data["end"].strip())
    if start is not None and end is not None:
        mydata = {
                "id": id,
                "start": start,
                "end": end,
                "year": datetime.datetime.strptime(start, "%Y-%m-%dT%H:%M:%SZ").year
            }

        if len(data["media_url"].strip()) > 0:
            mydata["media_uri"] = "image:" + data['media_url']

        if len(data["source_date"].split(';')) > 1:
            if all([len(data["source_" + x].split(';')) == len(data["source_date"].split(';')) for x in ["title", "author", "url", "citation"]]) is False:
                logging.info(data["source_date"])
                logging.info([len(data["source_" + x].split(';')) for x in ["title", "author", "url", "citation"]])
        
        for sd in data["source_date"].split(';'):
            sdp = parse_date(sd.strip())
            if sdp is not None:
                mydata["source_date"] = sdp
            elif len(data["source_date"].strip()) > 0:
                logging.error("invalid date: {0}".format(data["source_date"]))

            
        for s in split_fields:
            if len(data[s].strip()) > 0:
                mydata[s] = [x.strip() for x in data[s].split(',')]

        for s in split_fields2:
            if len(data[s].strip()) > 0:
                mydata[s] = [x.strip() for x in data[s].split(';')]

        for t in text_fields:
            if len(data[t].strip()) > 0:
                mydata[t] = data[t].strip()

        res = requests.post(SOLR_UPDATE_URL, data=json.dumps([mydata]),
                headers={'Content-Type': "application/json"})
        if res.status_code is not 200:
            logging.error("Error on line {0}: {1}".format(id, res.status_code))
    else:
        logging.error("Invalid date on line {0}: {1} {2}".format(id, data["start"], data["end"]))


if __name__ == "__main__":

    logging.basicConfig(level=logging.INFO)
    logging.getLogger("requests").setLevel(logging.WARNING)

    with open('data/lgbt_full.csv', 'rb') as fp:
        fieldnames = [
                'modified', 'contributor', 'reviewer', 'title', 'description',
                'start', 'end', 'category', 'region', 'country', 'municipality',
                'progress', 'people', 'organization', 'keyword', 'related',
                'symbol', 'legislation', 'source_title', 'source_author', 'source_date',
                'source_url', 'source_citation', 'text', 'media_title', 'media_credit',
                'media_url', 'media_caption']
                       
        reader = csv.DictReader(fp, delimiter=',', fieldnames=fieldnames)
        line = 1;
        for row in reader:
            date = None
            
            if line > 1:
                to_solr(line, row)

            line += 1

        requests.get(SOLR_UPDATE_URL + "?commit=true")
        logging.info("Added {0} documents to solr".format(line - 2))
