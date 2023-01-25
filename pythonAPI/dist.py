from math import sin, cos, sqrt, atan2, radians, degrees
"""

https://gis.stackexchange.com/questions/372400/kilometer-to-degree-and-back
"""

# Distances are measured in kilometers.
# Longitudes and latitudes are measured in degrees.
# Earth is assumed to be perfectly spherical.

EARTH_RADIUS = 6371.0

def change_in_latitude(kms):
    "Given a distance north, return the change in latitude."
    return degrees(kms/EARTH_RADIUS)

def change_in_longitude(latitude, kms):
    "Given a latitude and a distance west, return the change in longitude."
    # Find the radius of a circle around the earth at given latitude.
    r = EARTH_RADIUS*cos(radians(latitude))
    return degrees(kms/r)

def boundingBox(latitude, longitude, distance):
    """Given a position(latitude,longitude) X and a distance D in kms,
    returns a bounding box for points within D kms from X

    @returns (nlat, wlon, slat, elon)
    """
    slat, nlat = latitude+change_in_latitude(-distance), latitude+change_in_latitude(distance)
    wlon = longitude+change_in_longitude(latitude,-distance)
    elon = longitude+change_in_longitude(latitude, distance)
    return(nlat, wlon, slat, elon)

# https://www.movable-type.co.uk/scripts/latlong.html
def distanceInKms(slat, slon, elat, elon):

    slatradians = radians(slat)
    slonradians = radians(slon)
    elatradians = radians(elat)
    elonradians = radians(elon)

    dlon = elonradians - slonradians
    dlat = elatradians - slatradians


    a = sin(dlat / 2)**2 + cos(slatradians) * cos(elatradians) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    d = EARTH_RADIUS * c
    return d
