#!/usr/bin/env python3
import json
from flask import Flask, jsonify, current_app, Response
from werkzeug.exceptions import BadRequest
from werkzeug.serving import WSGIRequestHandler

from stationsRecharge import StationRechargeProvider
from json import JSONEncoder, dumps
import ignItineraire
from dist import distanceInKms


class MyEncoder(JSONEncoder):
    def default(self, o):
        return o.__dict__


class MasterialesFlask(Flask):
    def __init__(self, *args, **kwargs):
        super(MasterialesFlask, self).__init__(*args, **kwargs)
        self.stationsProvider = StationRechargeProvider()
        self.geoServices = ignItineraire.GeoServices(self.stationsProvider)


app = MasterialesFlask(__name__)


@app.route('/stationsInRange/position=<float:lat>,<float:lon>&range=<float:range>')
def stations_in_range(lat, lon, range):
    res = current_app.stationsProvider.getStationsInRange(lat, lon, range)
    return Response(dumps(res, cls=MyEncoder), mimetype='application/json')


@app.route('/itineraire/position=<float:slat>,<float:slon>&destination=<float:elat>,<float:elon>&range=<float:range>')
def calculItineraire(slat, slon, elat, elon, range):
    
    r = ignItineraire.CarRequestBuilder().buildSimpleRequest((slat, slon), (elat, elon))
    #res = current_app.geoServices.calculItineraire(r)
    with (open('Ressources\path_test.json')) as file:
        # load data
        res = json.load(file)
    
    #res = current_app.geoServices.calculItineraireXYRange((slat, slon), (elat, elon), range)
    return Response(dumps(res), mimetype='application/json')


if __name__ == '__main__':
    # running the app
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run(threaded=True)

    #res = ignItineraire.GeoServices(StationRechargeProvider()).calculItineraireXYRange((48.6158982, 2.42770525), (48.709696, 2.167326), 15)
    #print(res)

    #s = ignItineraire.GeoServices()
    #r = ignItineraire.simpleCarRequestBuilder().build((48.6158982, 2.42770525), (48.709696, 2.167326))
    # print(r.toString())
    # s.calculItineraire(r)
