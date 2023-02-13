#!/usr/bin/env python3
import json
from flask import Flask, jsonify, current_app, Response
from werkzeug.exceptions import BadRequest
from werkzeug.serving import WSGIRequestHandler

from stationsRecharge import StationRechargeProvider
from json import JSONEncoder, dumps
import ignItineraire
from dist import distanceInKms
from battery import BatteryEmulator


class MyEncoder(JSONEncoder):
    def default(self, o):
        return o.__dict__


class MasterialesFlask(Flask):
    def __init__(self, *args, **kwargs):
        super(MasterialesFlask, self).__init__(*args, **kwargs)
        self.stationsProvider = StationRechargeProvider()
        self.geoServices = ignItineraire.GeoServices(self.stationsProvider)
        self.battery = BatteryEmulator(1)


app = MasterialesFlask(__name__)


# ROUTE API

@app.route('/stationsInRange/position=<float:lat>,<float:lon>&range=<float:range>')
def stations_in_range(lat, lon, range):
    res = current_app.stationsProvider.getStationsInRange(lat, lon, range)
    return Response(dumps(res, cls=MyEncoder), mimetype='application/json')


@app.route('/itineraire/position=<float:slat>,<float:slon>&destination=<float:elat>,<float:elon>&range=<float:range>')
def calculItineraire(slat, slon, elat, elon, range):

    #r = ignItineraire.CarRequestBuilder().buildSimpleRequest((slat, slon), (elat, elon))
    #res = current_app.geoServices.calculItineraire(r)
    with (open('Ressources\path_test.json')) as file:
        # load data
        res = json.load(file)

    #res = current_app.geoServices.calculItineraireXYRange((slat, slon), (elat, elon), range)
    return Response(dumps(res), mimetype='application/json')


# BATTERY API

@app.route('/battery/status')
def getAvailableRange():
    res = {"charge": current_app.battery.getCharge(
    ), "range": current_app.battery.getAvailableRangeKms()}
    return Response(dumps(res), mimetype='application/json')


@app.route('/battery/setDriving')
def setDriving():
    current_app.battery.setDriving()
    return "200"


@app.route('/battery/setCharging')
def setCharging():
    current_app.battery.setCharging()
    return "200"


@app.route('/battery/setStopped')
def setStopped():
    current_app.battery.setStopped()
    return "200"


# MAIN EXECUTION
if __name__ == '__main__':
    # running the app
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run(threaded=True)

    # Paris-Marseille
    #res = ignItineraire.GeoServices(StationRechargeProvider()).calculItineraireXYRange((48.855595, 2.338286), (43.296292, 5.373333), 150)
    # print(res)

    #s = ignItineraire.GeoServices()
    #r = ignItineraire.simpleCarRequestBuilder().build((48.6158982, 2.42770525), (48.709696, 2.167326))
    # print(r.toString())
    # s.calculItineraire(r)
