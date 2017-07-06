import os
import re
import sys
import json
import socket
import urllib
import datetime
import subprocess


_station_re = re.compile(r'\s+(Hbf|hl\.?\s+n\.?)$(?i)')
_pattern_re = re.compile(r':([a-z_+]+)')
socket.setdefaulttimeout(5.0)


def parse_time(ts):
    return datetime.datetime.strptime(ts, '%Y-%m-%dT%H:%M:%S')


def strip_station(station):
    return _station_re.sub('', station)


def get_wifi_info():
    rv = {}
    for line in subprocess.Popen(
        ['airport', '--getinfo'],
        stdout=subprocess.PIPE).communicate()[0].splitlines():
        args = [x.strip().decode('utf-8') for x in line.split(b':')]
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
        status = obj._get_status_dict()
        if status is not None:
            rv = status
            for part in self.name.split('.'):
                rv = rv[part]
            return (self.ty or (lambda x: x))(rv)
        return self.default


class TransportInfo(object):
    type = 'unknown'
    default_template = ''
    is_available = False
    _cache = None

    def _fetch_status_dict(self):
        return None

    def _get_status_dict(self, refresh=False):
        if self._cache is not None and not refresh:
            return self._cache
        try:
            rv = self._fetch_status_dict()
            if rv is not None:
                self._cache = rv
                return rv
        except Exception:
            pass

    @property
    def is_available(self):
        return self._get_status_dict() is not None

    def get_data(self):
        return {'is_available': False}

    def get_template(self):
        return os.environ.get('%s_TEMPLATE' % self.type.upper()) \
            or self.default_template


class PlaneInfo(TransportInfo):
    type = 'plane'
    default_template = ':orig_airport to :dst_airport'

    dist_to_dst = None
    ground_speed = None
    is_online = False
    flight_number = None
    aircraft_type = None
    aircraft_registration = None
    orig_airport = None
    dst_airport = None
    ground_speed = None
    altitude = None
    dist_to_dst = None
    elapsed_time = None
    eta = None


class TrainInfo(TransportInfo):
    type = 'train'
    default_template = ':train_number'

    train_number = None
    orig_station = None
    dst_station = None
    eta = None


class AustrianPlaneInfo(PlaneInfo):

    def _fetch_status_dict(self):
        rv = urllib.urlopen('https://www.myaustrian-flynet.com/fapi/flightData')
        if rv.code == 200:
            return json.load(rv)

    @property
    def eta(self):
        d = (self._get_status_dict() or {}).get('dest')
        if d and 'localTimeAtArrival' in d:
            now = parse_time(d['localTime'])
            landing = parse_time(d['localTimeAtArrival'])
            minutes = (landing - now).total_seconds() // 60
        else:
            dist = self.dist_to_dst
            speed = self.ground_speed
            if dist is not None and speed:
                minutes = dist / (speed * 0.65) * 60
            else:
                return
        return '%02d:%02d' % (
            minutes // 60,
            int(minutes % 60),
        )

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


class OebbTrainInfo(TrainInfo):

    def _fetch_status_dict(self):
        rv = urllib.urlopen('http://railnet.oebb.at/api/trainInfo')
        if rv.code == 200:
            return json.load(rv)

    is_online = True

    @property
    def train_number(self):
        d = self._get_status_dict() or {}
        line = d.get('lineNumber')
        train_type = d.get('trainType')
        if line and train_type:
            return '%s-%s' % (train_type, line)
        return str(train_type or line or '')

    @property
    def orig_station(self):
        d = self._get_status_dict() or {}
        return strip_station((d.get('start') or {}).get('all'))

    @property
    def dst_station(self):
        d = self._get_status_dict() or {}
        return strip_station((d.get('destination') or {}).get('all'))

    @property
    def eta(self):
        d = self._get_status_dict() or {}
        arrival = d.get('lastStationArrivalForecast')
        if not arrival:
            return
        now = datetime.datetime.now()

        arr_hour, arr_minutes = map(int, arrival.split(':'))

        min_arrival = arr_hour * 60 + arr_minutes
        min_now = now.hour * 60 + now.minute

        minutes = max(min_arrival, min_now) - min(min_now, min_arrival)
        return '%02d:%02d' % (
            minutes // 60,
            int(minutes % 60),
        )


def get_transport_info():
    info = get_wifi_info()
    if info.get('SSID') == 'myAustrian FlyNet':
        info = AustrianPlaneInfo()
    elif info.get('SSID') == 'OEBB':
        info = OebbTrainInfo()
    else:
        return
    if info.is_available:
        return info


def prompt():
    info = get_transport_info()
    if info is None:
        return
    def _handle_match(m):
        x = m.group(1)
        if x == 'not_online_marker':
            if not info.is_online:
                return ' OFFLINE'
            return ''
        return str(getattr(info, x, None) or '')
    print(_pattern_re.sub(_handle_match, info.get_template()))


prompt()
