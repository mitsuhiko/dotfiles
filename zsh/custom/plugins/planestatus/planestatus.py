import os
import re
import sys
import json
import urllib
import subprocess


_pattern_re = re.compile(r':([a-z_+]+)')


def get_wifi_info():
    rv = {}
    for line in subprocess.Popen(
        ['airport', '--getinfo'],
        stdout=subprocess.PIPE).communicate()[0].splitlines():
        args = [x.strip() for x in line.split(':')]
        if len(args) == 2:
            rv[args[0]] = args[1]
    return rv


class StatusProperty(object):

    def __init__(self, name, default=None, ty=None):
        self.name = name
        self.default = default
        self.ty = ty

    def __get__(self, obj, type=None):
        if obj is None:
            return self
        status = obj.get_plane_status()
        if status is not None:
            rv = status
            for part in self.name.split('.'):
                rv = rv[part]
            return (self.ty or (lambda x: x))(rv)
        return self.default


class AustrianPlaneInfo(object):

    def __init__(self):
        self._cache = None

    def get_plane_status(self, refresh=False):
        if self._cache is not None and not refresh:
            return self._cache
        try:
            rv = urllib.urlopen('https://www.myaustrian-flynet.com/fapi/flightData')
            if rv.code == 200:
                self._cache = json.load(rv)
                return self._cache
        except Exception:
            pass

    @property
    def is_available(self):
        return self.get_plane_status() is not None

    is_online = StatusProperty('internetAvailable', default=False)
    flight_number = StatusProperty('flightNumber')
    aircraft_type = StatusProperty('aircraftType')
    aircraft_registration = StatusProperty('aircraftRegistration')
    orig_airport = StatusProperty('orig.code')
    dst_airport = StatusProperty('dest.code')
    ground_speed = StatusProperty('groundSpeed')
    altitude = StatusProperty('altitude')
    dist_to_dst = StatusProperty('distDest', ty=float)
    elapsed_time = StatusProperty('elapsedFlightTime')

    @property
    def eta(self):
        dist = self.dist_to_dst
        speed = self.ground_speed
        if dist is not None and speed is not None:
            minutes = dist / (speed * 0.8) * 60
            return '%02d:%02d' % (
                minutes // 60,
                int(minutes % 60),
            )

    def get_data(self):
        rv = {}
        for key in dir(self):
            val = getattr(self.__class__, key, None)
            if isinstance(val, StatusProperty):
                rv[key] = val.__get__(self)
        rv['eta'] = self.eta
        return rv


def get_plane_info():
    info = get_wifi_info()
    if info.get('SSID') == 'myAustrian FlyNet':
        info = AustrianPlaneInfo()
    else:
        return
    if info.is_available:
        return info


def prompt():
    info = get_plane_info()
    if info is None:
        return
    data = info.get_data()
    tmpl = os.environ.get('TEMPLATE') or ':orig_airport to :dst_airport'
    def _handle_match(m):
        x = m.group(1)
        if x == 'not_online_marker':
            if not info.is_online:
                return ' OFFLINE'
            return ''
        return str(data.get(x) or '')
    print(_pattern_re.sub(_handle_match, tmpl))


prompt()
