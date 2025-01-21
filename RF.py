import math

class RFBox:
    def __init__(self, gain, power, frequency, beamwidth, bandwidth):
        self.gain      = gain
        self.power     = power
        self.frequency = frequency
        self.beamwidth = beamwidth
        self.bandwidth = bandwidth
        self.splitBandwidthValid = False
        self.controlBandwidth = None
        self.dataBandwidth = None
    
    def splitBandwidth(self, controlBandwidth, dataBandwidth):
        self.splitBandwidthValid = True
        self.controlBandwidth = controlBandwidth
        self.dataBandwidth = dataBandwidth

def define_gain(beamwidth):
    return 10 * math.log10((4*math.pi) / (math.radians(beamwidth)**2))
        