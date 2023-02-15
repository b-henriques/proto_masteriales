import requests
from dist import distanceInKms
from math import floor
import json

"""
https://geoservices.ign.fr/documentation/services/api-et-services-ogc/geocodage-20/doc-technique-api-autocompletion

https://geoservices.ign.fr/documentation/services/api-et-services-ogc/geocodage-20/doc-technique-api-geocodage

https://geoservices.ign.fr/documentation/services/api-et-services-ogc/itineraires/api
https://geoservices.ign.fr/documentation/services/api-et-services-ogc/itineraires/documentation-du-service-du-calcul
"""


CALCUL_ITINERAIRE_URL = "https://wxs.ign.fr/calcul/geoportail/itineraire/rest/1.0.0/route?"
PROFILE_CAR = "car"
RESSOURCE_OSRM = "bdtopo-osrm"
RESSOURCE_PG_ROUTING = "bdtopo-pgr"
OPTIMIZATION_FASTEST = "fastest"
OPTIMIZATION_SHORTEST = "shortest"
GEOMETRY_GEOJSON = "geojson"
DISTANCE_UNIT_KMS = "kilometer"
DISTANCE_UNIT_METERS = "meter"


class GeoServices:

    def __init__(self, stationsProvider) -> None:
        self.stationsProvider = stationsProvider

    def calculItineraire(self, requete):
        response_API = requests.get(CALCUL_ITINERAIRE_URL+requete.toString())
        if(response_API.status_code == 200):
            json = response_API.json()
        return json

    def calculItineraireXYRange(self, start, end, range):
        """ Calculates shortest path between start and end, 
        passing through a recharge station (minimising detour) if direct path between start and end is > range
        """

        # if going straight to end is shorter than range then return path
        r = CarRequestBuilder().buildSimpleRequest(
            (start[0], start[1]), (end[0], end[1]))
        res = self.calculItineraire(r)
        if(res["distance"] < range):
            return res

        # else calculate path passsing by a chargcing station

        # get stations in range
        stationsInRange = self.stationsProvider.getStationsInRange(
            start[0], start[1], range)
        # sort them by dist
        sortedStationsByDirectDistance = self.sortStationsByDirectDistance(
            start, end, stationsInRange)

        # initiate minPathDist
        stationKey = sortedStationsByDirectDistance[0].key
        station = self.stationsProvider.stationsRechargeData[stationKey]
        minPathDist, jsonPath = self.shortestPathDist(start, end, station)
        """
        print(len(sortedStationsByDirectDistance))
        # remove stations wich directDistance is superior than minPathDist
        sortedStationsByDirectDistance = self.removeStationsWithSuperiorDistance(
            stations=sortedStationsByDirectDistance,
            dist=minPathDist,
            removeFirst=False,
            i=0,
            j=len(sortedStationsByDirectDistance)-1
        )


        # find the station wich minimizes detour
        while(len(sortedStationsByDirectDistance) > 1):
            print(len(sortedStationsByDirectDistance))
            # get the next station
            stationPrimeKey = sortedStationsByDirectDistance[1].key
            stationPrime = self.stationsProvider.stationsRechargeData[stationPrimeKey]

            # calculate path dist between start and end passing by stationPrime
            pathDist, jsonPathPrime = self.shortestPathDist(
                start, end, stationPrime)

            # if pathDist <= minPathDist update minPathDist
            if (pathDist <= minPathDist):
                minPathDist, jsonPath = pathDist, jsonPathPrime

                sortedStationsByDirectDistance = self.removeStationsWithSuperiorDistance(
                    stations=sortedStationsByDirectDistance,
                    dist=minPathDist,
                    removeFirst=True,
                    i=0,
                    j=len(sortedStationsByDirectDistance)-1
                )
            else:
                del(sortedStationsByDirectDistance[1])
        print(minPathDist)
        print(sortedStationsByDirectDistance)
        """
        return jsonPath

    def sortStationsByDirectDistance(self, start, end, stations):
        # res = list( (stationKey, distance))
        res = []

        for station in stations:

            distStartToStation = distanceInKms(
                start[0],
                start[1],
                float(station.consolidated_latitude),
                float(station.consolidated_longitude)
            )
            distStationToEnd = distanceInKms(
                float(station.consolidated_latitude),
                float(station.consolidated_longitude),
                end[0],
                end[1]
            )

            d = distStartToStation + distStationToEnd

            res = self.insertStationDist(res, station, d)

        return res

    def insertStationDist(self, res, station, d):
        tmp = []

        if len(res) == 0:
            return [KeyDist(station.coordonneesXY, d)]

        added = False
        for i in range(len(res)):
            if(d <= res[i].dist and not added):
                tmp.append(KeyDist(station.coordonneesXY, d))
                added = True
            tmp.append(res[i])
        if not added:
            tmp.append(KeyDist(station.coordonneesXY, d))
        return tmp

    def shortestPathDist(self, start, end, station):
        r = CarRequestBuilder().buildRequestXiY(start, end, station)
        json = self.calculItineraire(r)
        dist = json["distance"]
        return dist, json

    def removeStationsWithSuperiorDistance(self, stations, dist, removeFirst, i, j):

        if removeFirst:
            stations = stations[1:]
            return self.removeStationsWithSuperiorDistance(stations, dist, False, 0, len(stations)-1)

        if i > j:
            raise Exception("start index must be inferiour to end index")

        if i == j:
            if stations[i].dist > dist:
                return [stations[i]]
            return None

        # i<j
        k = floor((i+j)/2)
        if(stations[k].dist > dist):
            return self.removeStationsWithSuperiorDistance(stations, dist, False, i, k)
        else:  # stations[k].dist<=dist
            o = self.removeStationsWithSuperiorDistance(
                stations, dist, False, k+1, j)
            if o != None:
                res = stations[i:k+1]
                res.extend(o)
                return res
            else:
                return stations[i:k+1]


class KeyDist:
    def __init__(self, key, dist) -> None:
        self.key = key
        self.dist = dist

    def __repr__(self) -> str:
        return "("+self.key+";"+str(self.dist)+")"

    def __str__(self) -> str:
        return "("+self.key+";"+str(self.dist)+")"


class CarRequestBuilder:

    def buildSimpleRequest(self, start, end):
        requete = RequeteItineraire()
        requete.addStart(start[0], start[1]
                         ).addEnd(end[0], end[1]
                                  ).addProfile(PROFILE_CAR
                                               ).addGeometry(GEOMETRY_GEOJSON
                                                             ).addRessource(RESSOURCE_OSRM
                                                                            ).addOptimization(OPTIMIZATION_SHORTEST
                                                                                              ).addDistanceUnit(DISTANCE_UNIT_KMS)
        return requete

    def buildRequestXiY(self, start, end, station):
        requete = self.buildSimpleRequest(start, end).addIntermidiate(
            (station.consolidated_latitude, station.consolidated_longitude))
        return requete


class RequeteItineraire:

    def __init__(self) -> None:
        self.requete = ''

    def toString(self):
        return self.requete

    def addStart(self, lat, lon):
        self.requete = self.requete+f"&start={lon},{lat}"
        return self

    def addEnd(self, lat, lon):
        self.requete = self.requete+f"&end={lon},{lat}"
        return self

    def addOptimization(self, opt):
        self.requete = self.requete+f"&optimization={opt}"
        return self

    def addProfile(self, prof):
        self.requete = self.requete+f"&profile={prof}"
        return self

    def addRessource(self, ress):
        self.requete = self.requete+f"&resource={ress}"
        return self

    def addGeometry(self, geo):
        self.requete = self.requete+f"&geometryFormat={geo}"
        return self

    def addGetBbox(self, getbbox):
        self.requete = self.requete+f"&getBbox={getbbox}"
        return self

    def addGetSteps(self, getsteps):
        self.requete = self.requete+f"&getSteps={getsteps}"
        return self

    def addDistanceUnit(self, distanceUnit):
        self.requete = self.requete+f"&distanceUnit={distanceUnit}"
        return self

    def addIntermidiate(self, intermidiate):
        self.requete = self.requete + \
            f"&intermediates={intermidiate[1]},{intermidiate[0]}"
        return self
    # TODO:

    def addIntermediates(self, ptsIntermediaires):
        return self
