from time import sleep
from threading import Timer
import random

FULL_BATTERY_RANGE = 300  # in kms
UPDATE_INTERVAL = 10  # in seconds


class Battery:
    def __init__(self, fullBatteryRangeKms) -> None:
        self.fullBatteryRangeKms = fullBatteryRangeKms
        self.chargePercentage = 100

    def decharge(self, val):
        self.chargePercentage = max(0, self.chargePercentage-val)

    def charge(self, val):
        self.chargePercentage = min(100, self.chargePercentage+val)

    def getAvailableRangeKms(self):
        return self.fullBatteryRangeKms*self.chargePercentage/100
    
    def getCharge(self):
        return self.chargePercentage


class BatteryEmulator():

    def __init__(self, interval):
        self.battery = Battery(FULL_BATTERY_RANGE)

        self.timer = None
        self.interval = interval

        self.b_driving = False
        self.b_charging = False

        self.run()

    def update(self):
        #print(self.battery.getAvailableRangeKms())
        if self.b_driving:
            self.battery.decharge(random.random())
        if self.b_charging:
            self.battery.charge(1)
        self.run()

    def run(self):
        self.timer = Timer(self.interval, self.update)
        self.timer.start()

    def stop(self):
        self.timer.cancel()

    def setDriving(self):
        self.b_driving = True
        self.b_charging = False

    def setCharging(self):
        self.b_driving = False
        self.b_charging = True

    def setStopped(self):
        self.b_driving = False
        self.b_charging = False

    def getAvailableRangeKms(self):
        return self.battery.getAvailableRangeKms()

    def getCharge(self):
        return self.battery.getCharge()
