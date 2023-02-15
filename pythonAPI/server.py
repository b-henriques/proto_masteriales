#!/usr/bin/env python3
import json
from flask import Flask, jsonify, current_app, Response, make_response
from werkzeug.serving import WSGIRequestHandler

from stationsRecharge import StationRechargeProvider
from json import JSONEncoder, dumps
import ignItineraire
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
    # with (open('Ressources\path_test.json')) as file:
    #     # load data
    #     res = json.load(file)

    res = current_app.geoServices.calculItineraireXYRange((slat, slon), (elat, elon), range)
    return Response(dumps(res), mimetype='application/json', headers={})


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
    app.run(threaded=True, host="0.0.0.0")

    #
    # res = ignItineraire.GeoServices(StationRechargeProvider()).calculItineraireXYRange((48.62525, 2.4404133), (48.895347, 2.31048), 300)
    # print(json.dumps(res))
    # with (open('Ressources\path_test.json', 'w')) as file:
    #     # load data
    #         file.write(json.dumps(res))
    # print("DONE")
    # print(res)
